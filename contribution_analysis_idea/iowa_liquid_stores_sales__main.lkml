view: iowa_liquor_sales_sales {
  derived_table: {
    sql: select * from `bigquery-public-data.iowa_liquor_sales.sales`;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }
  dimension: invoice_and_item_number {}

  dimension: date {
    type: date
    datatype: date
  }

  dimension: store_number {}

  dimension: store_name {}

  dimension: address {}

  dimension: city {}

  dimension: zip_code {}

  dimension: store_location {}

  dimension: county_number {}

  dimension: county {}

  dimension: category {}

  dimension: category_name {}

  dimension: vendor_number {}

  dimension: vendor_name {}

  dimension: item_number {}

  dimension: item_description {}

  dimension: pack {
    type: number
  }

  dimension: bottle_volume_ml {
    type: number
  }

  dimension: state_bottle_cost {
    type: number
  }

  dimension: state_bottle_retail {
    type: number
  }

  dimension: bottles_sold {
    type: number
  }

  dimension: sale_dollars {
    type: number
  }

  dimension: volume_sold_liters {
    type: number
  }

  dimension: volume_sold_gallons {
    type: number
  }

  set: detail {
    fields: [
      invoice_and_item_number,
      date,
      store_number,
      store_name,
      address,
      city,
      zip_code,
      store_location,
      county_number,
      county,
      category,
      category_name,
      vendor_number,
      vendor_name,
      item_number,
      item_description,
      pack,
      bottle_volume_ml,
      state_bottle_cost,
      state_bottle_retail,
      bottles_sold,
      sale_dollars,
      volume_sold_liters,
      volume_sold_gallons
    ]
  }
}

view: +iowa_liquor_sales_sales {
  dimension_group: sale_date {
    type: time
    datatype: date
    sql: ${date} ;;
  }
}



explore: iowa_liquor_sales_sales {}

view: insights {
#   derived_table: {
#     sql:
# SELECT
#   *
# FROM ML.GET_INSIGHTS(
#   MODEL thekitchentable.iowaliquor.iowa_liquor_sales_contribution_analysis_model)
# ORDER BY unexpected_difference DESC
#     ;;
#   }
# sql_table_name:
# (SELECT
#   *
# FROM ML.GET_INSIGHTS(
#   MODEL thekitchentable.iowaliquor.iowa_liquor_sales_contribution_analysis_model)
# ORDER BY unexpected_difference DESC)
# ;;

    derived_table: {
      persist_for: "24 hour"

      create_process: {

        ## STEP 1: create or replace the training data table
        sql_step:
--following contribution analysis blog https://cloud.google.com/blog/products/data-analytics/introducing-a-new-contribution-analysis-model-in-bigquery
CREATE OR REPLACE TABLE thekitchentable.iowaliquor.iowa_liquor_sales_control_and_test AS
(SELECT
  store_name,
  city,
  vendor_name,
  category_name,
  item_description,
  SUM(sale_dollars) AS total_sales,
  FALSE AS is_test
FROM `bigquery-public-data.iowa_liquor_sales.sales`
WHERE EXTRACT(YEAR FROM date) = 2022
and sale_dollars>0 --resolve error For Contribution Analysis models with a min_apriori_support value greater than 0, all 'total_sales' values must be non-negative.
GROUP BY store_name, city, vendor_name,
  category_name, item_description, is_test
)
UNION ALL
(SELECT
  store_name,
  city,
  vendor_name,
  category_name,
  item_description,
  SUM(sale_dollars) AS total_sales,
  TRUE AS is_test
FROM `bigquery-public-data.iowa_liquor_sales.sales`
WHERE EXTRACT(YEAR FROM date) = 2023
and sale_dollars>0 --resolve error For Contribution Analysis models with a min_apriori_support value greater than 0, all 'total_sales' values must be non-negative.
GROUP BY store_name, city, vendor_name,
  category_name, item_description, is_test
)
            ;;

        sql_step:
CREATE OR REPLACE MODEL thekitchentable.iowaliquor.iowa_liquor_sales_contribution_analysis_model
  OPTIONS(
    model_type = 'CONTRIBUTION_ANALYSIS',
    contribution_metric =
      'sum(total_sales)',
    dimension_id_cols = ['store_name', 'city',
      'vendor_name', 'category_name', 'item_description'],
    is_test_col = 'is_test',
    min_apriori_support = 0.05
) AS
SELECT * FROM thekitchentable.iowaliquor.iowa_liquor_sales_control_and_test;
          ;;

      sql_step:
CREATE OR REPLACE TABLE ${SQL_TABLE_NAME} AS
(SELECT
   *
 FROM ML.GET_INSIGHTS(
   MODEL thekitchentable.iowaliquor.iowa_liquor_sales_contribution_analysis_model)
 ORDER BY unexpected_difference DESC)
      ;;
    }
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: contributors {}

  dimension: store_name {}

  dimension: city {}

  dimension: vendor_name {}

  dimension: category_name {}

  dimension: item_description {}

  dimension: metric_test {
    type: number}

  dimension: metric_control {
    type: number
  }

  dimension: difference {
    type: number
  }

  dimension: relative_difference {
    type: number
  }

  dimension: unexpected_difference {
    type: number
  }

  dimension: relative_unexpected_difference {
    type: number
  }

  dimension: apriori_support {
    type: number
  }

  dimension: contribution {
    type: number
    drill_fields: [detail*]
  }
  dimension: contribution_string_concat {
    sql: ARRAY_TO_STRING(${contributors},';') ;;
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      contributors,
      store_name,
      city,
      vendor_name,
      category_name,
      item_description,
      metric_test,
      metric_control,
      difference,
      relative_difference,
      unexpected_difference,
      relative_unexpected_difference,
      apriori_support,
      contribution
    ]
  }

}

view: +insights {
  dimension: contributor_array_length {
    type: number
    sql: ARRAY_LENGTH(${contributors}) ;;
  }

  measure: total_unexpected_difference {
    type: sum
    sql: ${unexpected_difference} ;;
  }
  measure: total_difference {
    type: sum
    sql: ${difference} ;;
  }
  measure: unexpected_difference_positive {
    type: number
    sql: case when ${total_unexpected_difference}>0 then ${total_unexpected_difference} else null end ;;
  }
  measure: unexpected_difference_loss {
    type: number
    sql: case when ${total_unexpected_difference}>0 then null else -1*${total_unexpected_difference} end ;;
  }
  measure: unexpected_difference_loss_as_negative {
    type: number
    sql: case when ${total_unexpected_difference}>0 then null else ${total_unexpected_difference} end ;;
  }
  measure: total_expected_difference {
    type: sum
    sql: ${difference}-${unexpected_difference} ;;
  }
  measure: expected_difference_base {
    # type: sum
    # sql: ${difference}-${unexpected_difference} ;;
    type: number
    sql: case when ${total_unexpected_difference}>0 then ${total_expected_difference} else ${total_expected_difference}+${total_unexpected_difference} end ;;
  }
  # measure: unexpected_difference_addon {
  #   # type: sum
  #   # sql: ${difference}-${unexpected_difference} ;;
  #   type: number
  #   sql: case when ${total_unexpected_difference}>0 then ${total_expected_difference} else -1*${unexpected_difference_loss} end ;;
  # }
  measure: total_relative_unexpected_difference {
    type: sum
    sql: ${relative_unexpected_difference} ;;
  }
}

explore: insights {}
