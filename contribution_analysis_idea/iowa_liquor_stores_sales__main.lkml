#autogen iowa_liquior_sales
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
  #autogen detail set
  set: detail {fields: [invoice_and_item_number,date,store_number,store_name,address,city,zip_code,store_location,county_number,county,category,category_name,vendor_number,vendor_name,item_number,item_description,pack,bottle_volume_ml,state_bottle_cost,state_bottle_retail,bottles_sold,sale_dollars,volume_sold_liters,volume_sold_gallons]}
}


view: +iowa_liquor_sales_sales {
  dimension_group: sale_date {
    type: time
    datatype: date
    sql: ${date} ;;
  }
  #test combinations
  measure: count_pack_month_and_vendor_combos {
    type: number
    sql: count(distinct concat(${pack},${sale_date_month},${vendor_name})) ;;
  }

  measure: total_sales {type: sum sql: ${sale_dollars} ;; drill_fields:[bottle_volume_ml,bottles_sold,category_name,pack,sale_date_month,total_sales]
  #override the drill link to send initiate writing results to a specific location
    html:
    {% assign model_and_explore = _model['_name'] | append:'/' | append: _explore['_name'] %}
    {% assign updated_link = link | replace: model_and_explore, 'test_procedural_bq_syntax/test_procedural_bq_syntax' %}
    {% assign dont_select_target_field = updated_link | replace: 'iowa_liquor_sales_sales.category_name,',''%}
    {% assign test_field_filter_removed = dont_select_target_field | replace: 'CANADIAN+WHISKIES',''%}
    {% assign set_test_field = test_field_filter_removed | append: '&dynamic_fields=[{"category":"dimension","expression":"${iowa_liquor_sales_sales.category_name}=\"CANADIAN+WHISKIES\"","label":"is_test","value_format":null,"value_format_name":null,"dimension":"is_test","_kind_hint":"dimension","_type_hint":"yesno"}]' %}
    {% assign add_is_test_field_to_selected_fields = set_test_field | replace: '?fields=', '?fields=is_test,' %}
    {% assign add_filter_on_measure = add_is_test_field_to_selected_fields | replace: 'query_timezone', '&f[iowa_liquor_sales_sales.total_sales]=>0&query_timezone' %}

    {% assign compiled_message = '&f[script_start.test_entry]= drilled on catgegory' | append: '&query_timezone'  %}
    {% assign pass_custom_message_to_target_table_build = add_filter_on_measure | replace: 'query_timezone', compiled_message%}
    <a href="https://looker.thekitchentable.gccbianortham.joonix.net{{pass_custom_message_to_target_table_build}}">write drilldown to table </a>
    ;;
    }
# {% assign compiled_message = '&f[script_start.test_entry]=different message with spaces. final build url:' | append: add_filter_on_measure | append: '&query_timezone' | filterable_value %}
}

explore: iowa_liquor_sales_sales {}

### Inoput View {
# Define a table as base of contribution analysis
# set dimensions as appropriate for this case

view: input_view {
  derived_table: {
    explore_source: iowa_liquor_sales_sales {
      column: dimension_1 {field:iowa_liquor_sales_sales.category_name}#add your own fields
      column: dimension_2 {field:iowa_liquor_sales_sales.pack}

      column: test_dim {field:iowa_liquor_sales_sales.county}

      column: measure {field:iowa_liquor_sales_sales.total_sales}

      derived_column: is_test {sql:case when test_dim = 'ADAIR' then TRUE else FALSE END;;}
    }
  }
  dimension: dimension_1 {}
  dimension: dimension_2 {}
  dimension: is_test {}
  dimension: measure_as_a_dimension {sql:${TABLE}.measure;;}
  measure: total_measure {type:sum sql:${measure_as_a_dimension};;}
}
#expose an explore on input view for testing/and troubleshooting
explore: input_view {}

#build a model and then use it to generate insights table (i.e. the result of contribution analysis)
view: insights_table_test {
  extends: [insights] #insghts template has the lookml modelled output fields.
  parameter: test_param {

  }
  dimension: project_id_bq_variable {}
  dimension: session_variable {}
  derived_table: {


#? Can and should we do no persistance?
#1) with longer persistance, does it really not re-run create model? Seems so
#2) what if create_process sql changes (e.g. based on parameter) - Causes it to re-run, which seems perfect (only rehuilds if results will be different)
    persist_for: "24 hour" #looker throws validation error if no persistance is set.
    # persist_for: "-1 hour"
    # persist_for: "1 second"

#can we set bq variables and other procedural syntax using create_process?
    # create_process: {
    #   sql_step:

    #   DECLARE x INT64;
    #   SET x = 5;
    #   ;;
    #   ## STEP 1: create or replace the training data table
    #   sql_step:

    #   --test if params can be exposed in create process?
    #   --test_param: {{test_param._parameter_value}} - {% parameter test_param %}
    #   --user_attribute: {{_user_attributes['email']}}
    #   --project_id:
    #   --following contribution analysis blog https://cloud.google.com/blog/products/data-analytics/introducing-a-new-contribution-analysis-model-in-bigquery
    #   CREATE OR REPLACE TABLE thekitchentable.iowaliquor.contribution_analysis_insights_table_test AS
    #   (SELECT
    #     dimension_1,
    #     dimension_2,
    #     is_test,
    #     SUM(measure) total_measure,
    #   --FROM `bigquery-public-data.iowa_liquor_sales.sales`
    #   FROM ${input_view.SQL_TABLE_NAME} as input_view
    #   --WHERE 1=1 and sale_dollars>0 --resolve error For Contribution Analysis models with a min_apriori_support value greater than 0, all 'total_sales' values must be non-negative.
    #   GROUP BY all
    #   having SUM(measure)>x
    #   );
    #   ;;

    #   sql_step:
    #   CREATE OR REPLACE MODEL thekitchentable.iowaliquor.iowa_liquor_sales_contribution_analysis_model_test
    #     OPTIONS(
    #       model_type = 'CONTRIBUTION_ANALYSIS',
    #       contribution_metric =
    #         'sum(total_measure)',
    #       dimension_id_cols = ['dimension_1', 'dimension_2'],
    #       is_test_col = 'is_test',
    #       min_apriori_support = 0.001
    #   ) AS
    #   SELECT * FROM thekitchentable.iowaliquor.contribution_analysis_insights_table_test


    #   ;;

    #   sql_step:
    #   CREATE OR REPLACE TABLE ${SQL_TABLE_NAME} AS
    #   (SELECT
    #     *
    #     ,@@project_id as project_id_bq_variable
    #   -- ,x as session_variable
    #   FROM ML.GET_INSIGHTS(
    #     MODEL thekitchentable.iowaliquor.iowa_liquor_sales_contribution_analysis_model_test)
    #   ORDER BY unexpected_difference DESC)
    #   ;

    #         ;;
    # }
    create_process: {
      sql_step:

      DECLARE x INT64;
      SET x = 5;

      --STEP 1: create or replace the training data table
      --test if params can be exposed in create process?
      --test_param: {{test_param._parameter_value}} - {% parameter test_param %}
      --user_attribute: {{_user_attributes['email']}}
      --project_id:
      --following contribution analysis blog https://cloud.google.com/blog/products/data-analytics/introducing-a-new-contribution-analysis-model-in-bigquery
      CREATE OR REPLACE TABLE thekitchentable.iowaliquor.contribution_analysis_insights_table_test AS
      (SELECT
        dimension_1,
        dimension_2,
        is_test,
        SUM(measure) total_measure,
      --FROM `bigquery-public-data.iowa_liquor_sales.sales`
      FROM ${input_view.SQL_TABLE_NAME} as input_view
      --WHERE 1=1 and sale_dollars>0 --resolve error For Contribution Analysis models with a min_apriori_support value greater than 0, all 'total_sales' values must be non-negative.
      GROUP BY all
      having SUM(measure)>0
      );

      CREATE OR REPLACE MODEL thekitchentable.iowaliquor.iowa_liquor_sales_contribution_analysis_model_test
        OPTIONS(
          model_type = 'CONTRIBUTION_ANALYSIS',
          contribution_metric =
            'sum(total_measure)',
          dimension_id_cols = ['dimension_1', 'dimension_2'],
          is_test_col = 'is_test',
          min_apriori_support = 0.001
      ) AS
      SELECT * FROM thekitchentable.iowaliquor.contribution_analysis_insights_table_test
    ;
      CREATE OR REPLACE TABLE ${SQL_TABLE_NAME} AS
      (SELECT
        *
        ,@@project_id as project_id_bq_variable
       ,x as session_variable
      FROM ML.GET_INSIGHTS(
        MODEL thekitchentable.iowaliquor.iowa_liquor_sales_contribution_analysis_model_test)
      ORDER BY unexpected_difference DESC)
      ;
            ;;
    }
  }

}
  explore: insights_table_test {}

#errors appeared in validator when i wasn't working on this 5/30, so commented out
view: insights_table {
  # derived_table: {
  #   persist_for: "24 hour"

  #   create_process: {

  #     ## STEP 1: create or replace the training data table
  #     sql_step:
  #     --following contribution analysis blog https://cloud.google.com/blog/products/data-analytics/introducing-a-new-contribution-analysis-model-in-bigquery
  #     CREATE OR REPLACE TABLE thekitchentable.iowaliquor.iowa_liquor_sales_control_and_test AS
  #     (SELECT
  #       store_name,
  #       city,
  #       vendor_name,
  #       category_name,
  #       item_description,
  #       SUM(sale_dollars) AS total_sales,
  #       FALSE AS is_test
  #     FROM `bigquery-public-data.iowa_liquor_sales.sales`
  #     WHERE
  #     --EXTRACT(YEAR FROM date) = 2022
  #     EXTRACT(YEAR FROM date) = 2024 and EXTRACT(MONTH FROM date) = 1
  #     and sale_dollars>0 --resolve error For Contribution Analysis models with a min_apriori_support value greater than 0, all 'total_sales' values must be non-negative.
  #     GROUP BY store_name, city, vendor_name,
  #       category_name, item_description, is_test
  #     )
  #     UNION ALL
  #     (SELECT
  #       store_name,
  #       city,
  #       vendor_name,
  #       category_name,
  #       item_description,
  #       SUM(sale_dollars) AS total_sales,
  #       TRUE AS is_test
  #     FROM `bigquery-public-data.iowa_liquor_sales.sales`
  #     WHERE
  #     --EXTRACT(YEAR FROM date) = 2023
  #     EXTRACT(YEAR FROM date) = 2024 and EXTRACT(MONTH FROM date) = 2
  #     and sale_dollars>0 --resolve error For Contribution Analysis models with a min_apriori_support value greater than 0, all 'total_sales' values must be non-negative.
  #     GROUP BY store_name, city, vendor_name,
  #       category_name, item_description, is_test
  #     )
  #                 ;;

  #     sql_step:
  #     CREATE OR REPLACE MODEL thekitchentable.iowaliquor.iowa_liquor_sales_contribution_analysis_model
  #       OPTIONS(
  #         model_type = 'CONTRIBUTION_ANALYSIS',
  #         contribution_metric =
  #           'sum(total_sales)',
  #         dimension_id_cols = ['store_name', 'city',
  #           'vendor_name', 'category_name', 'item_description'],
  #         is_test_col = 'is_test',
  #         min_apriori_support = 0.001
  #     ) AS
  #     SELECT * FROM thekitchentable.iowaliquor.iowa_liquor_sales_control_and_test;
  #               ;;

  #     sql_step:
  #     CREATE OR REPLACE TABLE ${SQL_TABLE_NAME} AS
  #     (SELECT
  #       *
  #     FROM ML.GET_INSIGHTS(
  #       MODEL thekitchentable.iowaliquor.iowa_liquor_sales_contribution_analysis_model)
  #     ORDER BY unexpected_difference DESC)
  #           ;;
  #   }
  # }
}
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

#     derived_table: {
#       persist_for: "24 hour"

#       create_process: {

#         ## STEP 1: create or replace the training data table
#         sql_step:
# --following contribution analysis blog https://cloud.google.com/blog/products/data-analytics/introducing-a-new-contribution-analysis-model-in-bigquery
# CREATE OR REPLACE TABLE thekitchentable.iowaliquor.iowa_liquor_sales_control_and_test AS
# (SELECT
#   store_name,
#   city,
#   vendor_name,
#   category_name,
#   item_description,
#   SUM(sale_dollars) AS total_sales,
#   FALSE AS is_test
# FROM `bigquery-public-data.iowa_liquor_sales.sales`
# WHERE
# --EXTRACT(YEAR FROM date) = 2022
# EXTRACT(YEAR FROM date) = 2024 and EXTRACT(MONTH FROM date) = 1
# and sale_dollars>0 --resolve error For Contribution Analysis models with a min_apriori_support value greater than 0, all 'total_sales' values must be non-negative.
# GROUP BY store_name, city, vendor_name,
#   category_name, item_description, is_test
# )
# UNION ALL
# (SELECT
#   store_name,
#   city,
#   vendor_name,
#   category_name,
#   item_description,
#   SUM(sale_dollars) AS total_sales,
#   TRUE AS is_test
# FROM `bigquery-public-data.iowa_liquor_sales.sales`
# WHERE
# --EXTRACT(YEAR FROM date) = 2023
# EXTRACT(YEAR FROM date) = 2024 and EXTRACT(MONTH FROM date) = 2
# and sale_dollars>0 --resolve error For Contribution Analysis models with a min_apriori_support value greater than 0, all 'total_sales' values must be non-negative.
# GROUP BY store_name, city, vendor_name,
#   category_name, item_description, is_test
# )
#             ;;

#         sql_step:
# CREATE OR REPLACE MODEL thekitchentable.iowaliquor.iowa_liquor_sales_contribution_analysis_model
#   OPTIONS(
#     model_type = 'CONTRIBUTION_ANALYSIS',
#     contribution_metric =
#       'sum(total_sales)',
#     dimension_id_cols = ['store_name', 'city',
#       'vendor_name', 'category_name', 'item_description'],
#     is_test_col = 'is_test',
#     min_apriori_support = 0.05
# ) AS
# SELECT * FROM thekitchentable.iowaliquor.iowa_liquor_sales_control_and_test;
#           ;;

#       sql_step:
# CREATE OR REPLACE TABLE ${SQL_TABLE_NAME} AS
# (SELECT
#   *
# FROM ML.GET_INSIGHTS(
#   MODEL thekitchentable.iowaliquor.iowa_liquor_sales_contribution_analysis_model)
# ORDER BY unexpected_difference DESC)
#       ;;
#     }
#   }
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
    # html: <span style = "color:red">test</span> <br>t2;;
    html: {% assign pairs = _field._value | split: ';' %}
{% for entry in pairs %}
{{entry}}<br>
{% endfor %}
    ;;
    # <a href = "https://looker.thekitchentable.gccbianortham.joonix.net/explore/kevmccarthy_sandbox/insights?fields=insights.contributor_part_1_dimension,insights.contributor_part_1_value,insights.count,insights.total_relative_difference,all_insights_explore_cross_view_refererences.percent_of_grand_total,insights.total_relative_unexpected_difference,insights.contributor_part_1_dimension_value_pair,contributer_params.meets_min_abs_relative_unexpected_difference,insights.contribution_string_concat&f[insights.contributor_array_length]=&f[contributer_params.min_abs_relative_unexpected_difference]=0.1&f[all_insights_explore_cross_view_refererences.percent_of_grand_total]=%3E0.001&f[insights.contributor_part_1_value]=&f[insights.contributor_part_1_dimension]=&f[insights.contributor_part_1_dimension_value_pair]=%25category%5E_name%3DCANADIAN+WHISKIES%25&sorts=all_insights_explore_cross_view_refererences.percent_of_grand_total+desc&limit=5000&column_limit=50&vis=%7B%22x_axis_gridlines%22%3Afalse%2C%22y_axis_gridlines%22%3Atrue%2C%22show_view_names%22%3Afalse%2C%22show_y_axis_labels%22%3Atrue%2C%22show_y_axis_ticks%22%3Atrue%2C%22y_axis_tick_density%22%3A%22default%22%2C%22y_axis_tick_density_custom%22%3A5%2C%22show_x_axis_label%22%3Atrue%2C%22show_x_axis_ticks%22%3Atrue%2C%22y_axis_scale_mode%22%3A%22linear%22%2C%22x_axis_reversed%22%3Afalse%2C%22y_axis_reversed%22%3Afalse%2C%22plot_size_by_field%22%3Afalse%2C%22trellis%22%3A%22%22%2C%22stacking%22%3A%22%22%2C%22limit_displayed_rows%22%3Atrue%2C%22legend_position%22%3A%22center%22%2C%22point_style%22%3A%22circle%22%2C%22show_value_labels%22%3Atrue%2C%22label_density%22%3A25%2C%22x_axis_scale%22%3A%22linear%22%2C%22y_axis_combined%22%3Atrue%2C%22show_null_points%22%3Afalse%2C%22y_axes%22%3A%5B%7B%22label%22%3A%22Performance+vs+Population%22%2C%22orientation%22%3A%22top%22%2C%22series%22%3A%5B%7B%22axisId%22%3A%22insights.total_relative_unexpected_difference%22%2C%22id%22%3A%22insights.total_relative_unexpected_difference%22%2C%22name%22%3A%22Total+Relative+Unexpected+Difference%22%7D%5D%2C%22showLabels%22%3Atrue%2C%22showValues%22%3Atrue%2C%22maxValue%22%3A1%2C%22minValue%22%3A-1%2C%22valueFormat%22%3A%220%25%22%2C%22unpinAxis%22%3Afalse%2C%22tickDensity%22%3A%22default%22%2C%22tickDensityCustom%22%3A5%2C%22type%22%3A%22linear%22%7D%5D%2C%22size_by_field%22%3A%22%22%2C%22x_axis_zoom%22%3Atrue%2C%22y_axis_zoom%22%3Atrue%2C%22limit_displayed_rows_values%22%3A%7B%22show_hide%22%3A%22show%22%2C%22first_last%22%3A%22first%22%2C%22num_rows%22%3A%22500%22%7D%2C%22hide_legend%22%3Afalse%2C%22font_size%22%3A%2210%22%2C%22series_types%22%3A%7B%22insights.total_relative_unexpected_difference%22%3A%22column%22%7D%2C%22series_colors%22%3A%7B%22reference_0%22%3A%22%23000000%22%7D%2C%22series_labels%22%3A%7B%22reference_line_all%22%3A%22ALL%22%7D%2C%22series_point_styles%22%3A%7B%22reference_0%22%3A%22auto%22%7D%2C%22reference_lines%22%3A%5B%5D%2C%22trend_lines%22%3A%5B%5D%2C%22swap_axes%22%3Atrue%2C%22cluster_points%22%3Afalse%2C%22quadrants_enabled%22%3Afalse%2C%22quadrant_properties%22%3A%7B%220%22%3A%7B%22color%22%3A%22%22%2C%22label%22%3A%22Quadrant+1%22%7D%2C%221%22%3A%7B%22color%22%3A%22%22%2C%22label%22%3A%22Quadrant+2%22%7D%2C%222%22%3A%7B%22color%22%3A%22%22%2C%22label%22%3A%22Quadrant+3%22%7D%2C%223%22%3A%7B%22color%22%3A%22%22%2C%22label%22%3A%22Quadrant+4%22%7D%7D%2C%22custom_quadrant_point_x%22%3A5%2C%22custom_quadrant_point_y%22%3A5%2C%22custom_x_column%22%3A%22all_insights_explore_cross_view_refererences.percent_of_grand_total%22%2C%22custom_y_column%22%3A%22insights.total_relative_unexpected_difference%22%2C%22custom_value_label_column%22%3A%22insights.contribution_string_concat%22%2C%22advanced_vis_config%22%3A%22%7Bchart%3A%7B%7D%2Cseries%3A%5B%7Bname%3A%27Total+Relative+Difference%27%7D%2C%7Bname%3A%27Percent+of+Grand+Total%27%7D%5D%7D%22%2C%22ordering%22%3A%22none%22%2C%22show_null_labels%22%3Afalse%2C%22show_totals_labels%22%3Afalse%2C%22show_silhouette%22%3Afalse%2C%22totals_color%22%3A%22%23808080%22%2C%22show_row_numbers%22%3Atrue%2C%22transpose%22%3Afalse%2C%22truncate_text%22%3Atrue%2C%22hide_totals%22%3Afalse%2C%22hide_row_totals%22%3Afalse%2C%22size_to_fit%22%3Atrue%2C%22table_theme%22%3A%22white%22%2C%22enable_conditional_formatting%22%3Atrue%2C%22header_text_alignment%22%3A%22left%22%2C%22header_font_size%22%3A%2212%22%2C%22rows_font_size%22%3A%2212%22%2C%22conditional_formatting_include_totals%22%3Afalse%2C%22conditional_formatting_include_nulls%22%3Afalse%2C%22show_sql_query_menu_options%22%3Afalse%2C%22show_totals%22%3Atrue%2C%22show_row_totals%22%3Atrue%2C%22truncate_header%22%3Afalse%2C%22minimum_column_width%22%3A75%2C%22series_cell_visualizations%22%3A%7B%22insights.total_relative_difference%22%3A%7B%22is_active%22%3Atrue%2C%22palette%22%3A%7B%22palette_id%22%3A%227b654251-b6d2-b98c-a88f-92ca3d82aa47%22%2C%22collection_id%22%3A%227c56cc21-66e4-41c9-81ce-a60e1c3967b2%22%2C%22custom_colors%22%3A%5B%22%231a73e8%22%2C%22%231a73e8%22%5D%7D%7D%2C%22all_insights_explore_cross_view_refererences.percent_of_grand_total%22%3A%7B%22is_active%22%3Atrue%2C%22palette%22%3A%7B%22palette_id%22%3A%227be0c0fa-6523-6ae3-3b07-aa4bba9a7dc9%22%2C%22collection_id%22%3A%227c56cc21-66e4-41c9-81ce-a60e1c3967b2%22%2C%22custom_colors%22%3A%5B%22%233395ff%22%2C%22%233395ff%22%5D%7D%7D%7D%2C%22conditional_formatting%22%3A%5B%7B%22type%22%3A%22greater+than%22%2C%22value%22%3A0%2C%22background_color%22%3A%22%237CB342%22%2C%22font_color%22%3A%22%237CB342%22%2C%22color_application%22%3A%7B%22collection_id%22%3A%227c56cc21-66e4-41c9-81ce-a60e1c3967b2%22%2C%22palette_id%22%3A%224a00499b-c0fe-4b15-a304-4083c07ff4c4%22%2C%22options%22%3A%7B%22constraints%22%3A%7B%22min%22%3A%7B%22type%22%3A%22minimum%22%7D%2C%22mid%22%3A%7B%22type%22%3A%22number%22%2C%22value%22%3A0%7D%2C%22max%22%3A%7B%22type%22%3A%22maximum%22%7D%7D%2C%22mirror%22%3Atrue%2C%22reverse%22%3Afalse%2C%22stepped%22%3Afalse%7D%7D%2C%22bold%22%3Afalse%2C%22italic%22%3Afalse%2C%22strikethrough%22%3Afalse%2C%22fields%22%3A%5B%22insights.total_relative_difference%22%5D%7D%5D%2C%22series_value_format%22%3A%7B%7D%2C%22hidden_pivots%22%3A%7B%7D%2C%22hidden_fields%22%3A%5B%22insights.count%22%2C%22insights.total_relative_difference%22%2C%22insights.contributor_part_1_dimension%22%2C%22insights.contributor_part_1_value%22%2C%22insights.contributor_part_1_dimension_value_pair%22%5D%2C%22type%22%3A%22looker_scatter%22%2C%22defaults_version%22%3A1%2C%22hidden_points_if_no%22%3A%5B%22contributer_params.meets_min_abs_relative_unexpected_difference%22%5D%7D&filter_config=%7B%22insights.contributor_array_length%22%3A%5B%7B%22type%22%3A%22%3D%22%2C%22values%22%3A%5B%7B%22constant%22%3A%22%22%7D%2C%7B%7D%5D%2C%22id%22%3A6%7D%5D%2C%22contributer_params.min_abs_relative_unexpected_difference%22%3A%5B%7B%22type%22%3A%22%3D%22%2C%22values%22%3A%5B%7B%22constant%22%3A%220.1%22%7D%2C%7B%7D%5D%2C%22id%22%3A7%7D%5D%2C%22all_insights_explore_cross_view_refererences.percent_of_grand_total%22%3A%5B%7B%22type%22%3A%22%5Cu003e%22%2C%22values%22%3A%5B%7B%22constant%22%3A%220.001%22%7D%2C%7B%7D%5D%2C%22id%22%3A8%7D%5D%2C%22insights.contributor_part_1_value%22%3A%5B%7B%22type%22%3A%22%3D%22%2C%22values%22%3A%5B%7B%22constant%22%3A%22%22%7D%2C%7B%7D%5D%2C%22id%22%3A9%7D%5D%2C%22insights.contributor_part_1_dimension%22%3A%5B%7B%22type%22%3A%22%3D%22%2C%22values%22%3A%5B%7B%22constant%22%3A%22%22%7D%2C%7B%7D%5D%2C%22id%22%3A10%7D%5D%2C%22insights.contributor_part_1_dimension_value_pair%22%3A%5B%7B%22type%22%3A%22contains%22%2C%22values%22%3A%5B%7B%22constant%22%3A%22category_name%3DCANADIAN+WHISKIES%22%7D%2C%7B%7D%5D%2C%22id%22%3A11%7D%5D%2C%22__%21internal%21__%22%3A%5B%22OR%22%2C%5B%5B%22AND%22%2C%5B%5B%22FILTER%22%2C%7B%22field%22%3A%22insights.contributor_array_length%22%2C%22value%22%3A%22%22%2C%22type%22%3A%22%3D%22%7D%5D%2C%5B%22FILTER%22%2C%7B%22field%22%3A%22contributer_params.min_abs_relative_unexpected_difference%22%2C%22value%22%3A%220.1%22%2C%22type%22%3A%22%3D%22%7D%5D%2C%5B%22FILTER%22%2C%7B%22field%22%3A%22all_insights_explore_cross_view_refererences.percent_of_grand_total%22%2C%22value%22%3A%22%5Cu003e0.001%22%2C%22type%22%3A%22%5Cu003e%22%7D%5D%2C%5B%22FILTER%22%2C%7B%22field%22%3A%22insights.contributor_part_1_value%22%2C%22value%22%3A%22%22%2C%22type%22%3A%22match%22%7D%5D%2C%5B%22FILTER%22%2C%7B%22field%22%3A%22insights.contributor_part_1_dimension%22%2C%22value%22%3A%22%22%2C%22type%22%3A%22match%22%7D%5D%2C%5B%22FILTER%22%2C%7B%22field%22%3A%22insights.contributor_part_1_dimension_value_pair%22%2C%22value%22%3A%22%25category%5E_name%3DCANADIAN+WHISKIES%25%22%2C%22type%22%3A%22contains%22%7D%5D%5D%5D%5D%5D%7D&dynamic_fields=%5B%7B%22category%22%3A%22table_calculation%22%2C%22expression%22%3A%22concat%28%24%7Binsights.contributor_part_1_dimension%7D%2C%24%7Binsights.contributor_part_1_value%7D%29%22%2C%22label%22%3A%22t%22%2C%22value_format%22%3Anull%2C%22value_format_name%22%3Anull%2C%22_kind_hint%22%3A%22dimension%22%2C%22table_calculation%22%3A%22t%22%2C%22_type_hint%22%3A%22string%22%2C%22is_disabled%22%3Atrue%7D%5D&origin=share-expanded">link</a>
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
  dimension: contributor_part_1_dimension_value_pair {
    sql: ${contributors}[0] ;;
  }
  dimension: contributor_part_1_dimension {
    sql: split(${contributor_part_1_dimension_value_pair},'=')[0] ;;
  }
  dimension: contributor_part_1_value {
    sql: split(${contributor_part_1_dimension_value_pair},'=')[SAFE_OFFSET (1)] ;;
  }

  measure: grand_total_control {
    type: number
    sql: sum(sum(case when ${contribution_string_concat}='all' then ${metric_control} else 0 end)) over() ;;
    value_format_name: decimal_0
  }

  measure: percent_of_total_control {
    sql: sum(${metric_control}) / ${grand_total_control};;
    value_format_name: percent_1
  }

  measure: total_control {
    type: sum
    sql: ${metric_control} ;;
  }
  measure: total_test {
    type: sum
    sql: ${metric_test} ;;
  }

  measure: total_relative_difference {
    type: sum
    sql: ${relative_difference} ;;
    value_format_name: percent_1
  }

  measure: total_relative_unexpected_difference {
    # type: sum
    # sql: ${relative_unexpected_difference} ;;
    type: number
    sql: safe_divide(sum(${unexpected_difference}),sum(${metric_control})) ;;
    value_format_name: percent_1
    link: {
      label: "all subgroups (*needs testing: assumes contributor array will be presented in this order*)"
      url: "https://looker.thekitchentable.gccbianortham.joonix.net/explore/kevmccarthy_sandbox/insights?fields=insights.contributor_part_1_dimension,insights.contributor_part_1_value,insights.count,insights.total_relative_difference,all_insights_explore_cross_view_refererences.percent_of_grand_total,insights.total_relative_unexpected_difference,insights.contributor_part_1_dimension_value_pair,contributer_params.meets_min_abs_relative_unexpected_difference,insights.contribution_string_concat&f[insights.contributor_array_length]=&f[contributer_params.min_abs_relative_unexpected_difference]=0.1&f[all_insights_explore_cross_view_refererences.percent_of_grand_total]=%3E0.001&f[insights.contributor_part_1_value]=&f[insights.contributor_part_1_dimension]=&f[insights.contribution_string_concat]=%25{{contribution_string_concat | append: ';' | url_encode}}%25&sorts=all_insights_explore_cross_view_refererences.percent_of_grand_total+desc&limit=5000&column_limit=50&vis=%7B%22x_axis_gridlines%22%3Afalse%2C%22y_axis_gridlines%22%3Atrue%2C%22show_view_names%22%3Afalse%2C%22show_y_axis_labels%22%3Atrue%2C%22show_y_axis_ticks%22%3Atrue%2C%22y_axis_tick_density%22%3A%22default%22%2C%22y_axis_tick_density_custom%22%3A5%2C%22show_x_axis_label%22%3Atrue%2C%22show_x_axis_ticks%22%3Atrue%2C%22y_axis_scale_mode%22%3A%22linear%22%2C%22x_axis_reversed%22%3Afalse%2C%22y_axis_reversed%22%3Afalse%2C%22plot_size_by_field%22%3Afalse%2C%22trellis%22%3A%22%22%2C%22stacking%22%3A%22%22%2C%22limit_displayed_rows%22%3Atrue%2C%22legend_position%22%3A%22center%22%2C%22point_style%22%3A%22circle%22%2C%22show_value_labels%22%3Atrue%2C%22label_density%22%3A25%2C%22x_axis_scale%22%3A%22linear%22%2C%22y_axis_combined%22%3Atrue%2C%22show_null_points%22%3Afalse%2C%22y_axes%22%3A%5B%7B%22label%22%3A%22Performance+vs+Population%22%2C%22orientation%22%3A%22top%22%2C%22series%22%3A%5B%7B%22axisId%22%3A%22insights.total_relative_unexpected_difference%22%2C%22id%22%3A%22insights.total_relative_unexpected_difference%22%2C%22name%22%3A%22Total+Relative+Unexpected+Difference%22%7D%5D%2C%22showLabels%22%3Atrue%2C%22showValues%22%3Atrue%2C%22maxValue%22%3A1%2C%22minValue%22%3A-1%2C%22valueFormat%22%3A%220%25%22%2C%22unpinAxis%22%3Afalse%2C%22tickDensity%22%3A%22default%22%2C%22tickDensityCustom%22%3A5%2C%22type%22%3A%22linear%22%7D%5D%2C%22size_by_field%22%3A%22%22%2C%22x_axis_zoom%22%3Atrue%2C%22y_axis_zoom%22%3Atrue%2C%22limit_displayed_rows_values%22%3A%7B%22show_hide%22%3A%22show%22%2C%22first_last%22%3A%22first%22%2C%22num_rows%22%3A%22500%22%7D%2C%22hide_legend%22%3Afalse%2C%22font_size%22%3A%2210%22%2C%22series_types%22%3A%7B%22insights.total_relative_unexpected_difference%22%3A%22column%22%7D%2C%22series_colors%22%3A%7B%22reference_0%22%3A%22%23000000%22%7D%2C%22series_labels%22%3A%7B%22reference_line_all%22%3A%22ALL%22%7D%2C%22series_point_styles%22%3A%7B%22reference_0%22%3A%22auto%22%7D%2C%22reference_lines%22%3A%5B%5D%2C%22trend_lines%22%3A%5B%5D%2C%22swap_axes%22%3Atrue%2C%22cluster_points%22%3Afalse%2C%22quadrants_enabled%22%3Afalse%2C%22quadrant_properties%22%3A%7B%220%22%3A%7B%22color%22%3A%22%22%2C%22label%22%3A%22Quadrant+1%22%7D%2C%221%22%3A%7B%22color%22%3A%22%22%2C%22label%22%3A%22Quadrant+2%22%7D%2C%222%22%3A%7B%22color%22%3A%22%22%2C%22label%22%3A%22Quadrant+3%22%7D%2C%223%22%3A%7B%22color%22%3A%22%22%2C%22label%22%3A%22Quadrant+4%22%7D%7D%2C%22custom_quadrant_point_x%22%3A5%2C%22custom_quadrant_point_y%22%3A5%2C%22custom_x_column%22%3A%22all_insights_explore_cross_view_refererences.percent_of_grand_total%22%2C%22custom_y_column%22%3A%22insights.total_relative_unexpected_difference%22%2C%22custom_value_label_column%22%3A%22insights.contribution_string_concat%22%2C%22advanced_vis_config%22%3A%22%7Bchart%3A%7B%7D%2Cseries%3A%5B%7Bname%3A%27Total+Relative+Difference%27%7D%2C%7Bname%3A%27Percent+of+Grand+Total%27%7D%5D%7D%22%2C%22ordering%22%3A%22none%22%2C%22show_null_labels%22%3Afalse%2C%22show_totals_labels%22%3Afalse%2C%22show_silhouette%22%3Afalse%2C%22totals_color%22%3A%22%23808080%22%2C%22show_row_numbers%22%3Atrue%2C%22transpose%22%3Afalse%2C%22truncate_text%22%3Atrue%2C%22hide_totals%22%3Afalse%2C%22hide_row_totals%22%3Afalse%2C%22size_to_fit%22%3Atrue%2C%22table_theme%22%3A%22white%22%2C%22enable_conditional_formatting%22%3Atrue%2C%22header_text_alignment%22%3A%22left%22%2C%22header_font_size%22%3A%2212%22%2C%22rows_font_size%22%3A%2212%22%2C%22conditional_formatting_include_totals%22%3Afalse%2C%22conditional_formatting_include_nulls%22%3Afalse%2C%22show_sql_query_menu_options%22%3Afalse%2C%22show_totals%22%3Atrue%2C%22show_row_totals%22%3Atrue%2C%22truncate_header%22%3Afalse%2C%22minimum_column_width%22%3A75%2C%22series_cell_visualizations%22%3A%7B%22insights.total_relative_difference%22%3A%7B%22is_active%22%3Atrue%2C%22palette%22%3A%7B%22palette_id%22%3A%227b654251-b6d2-b98c-a88f-92ca3d82aa47%22%2C%22collection_id%22%3A%227c56cc21-66e4-41c9-81ce-a60e1c3967b2%22%2C%22custom_colors%22%3A%5B%22%231a73e8%22%2C%22%231a73e8%22%5D%7D%7D%2C%22all_insights_explore_cross_view_refererences.percent_of_grand_total%22%3A%7B%22is_active%22%3Atrue%2C%22palette%22%3A%7B%22palette_id%22%3A%227be0c0fa-6523-6ae3-3b07-aa4bba9a7dc9%22%2C%22collection_id%22%3A%227c56cc21-66e4-41c9-81ce-a60e1c3967b2%22%2C%22custom_colors%22%3A%5B%22%233395ff%22%2C%22%233395ff%22%5D%7D%7D%7D%2C%22conditional_formatting%22%3A%5B%7B%22type%22%3A%22greater+than%22%2C%22value%22%3A0%2C%22background_color%22%3A%22%237CB342%22%2C%22font_color%22%3A%22%237CB342%22%2C%22color_application%22%3A%7B%22collection_id%22%3A%227c56cc21-66e4-41c9-81ce-a60e1c3967b2%22%2C%22palette_id%22%3A%224a00499b-c0fe-4b15-a304-4083c07ff4c4%22%2C%22options%22%3A%7B%22constraints%22%3A%7B%22min%22%3A%7B%22type%22%3A%22minimum%22%7D%2C%22mid%22%3A%7B%22type%22%3A%22number%22%2C%22value%22%3A0%7D%2C%22max%22%3A%7B%22type%22%3A%22maximum%22%7D%7D%2C%22mirror%22%3Atrue%2C%22reverse%22%3Afalse%2C%22stepped%22%3Afalse%7D%7D%2C%22bold%22%3Afalse%2C%22italic%22%3Afalse%2C%22strikethrough%22%3Afalse%2C%22fields%22%3A%5B%22insights.total_relative_difference%22%5D%7D%5D%2C%22series_value_format%22%3A%7B%7D%2C%22hidden_pivots%22%3A%7B%7D%2C%22hidden_fields%22%3A%5B%22insights.count%22%2C%22insights.total_relative_difference%22%2C%22insights.contributor_part_1_dimension%22%2C%22insights.contributor_part_1_value%22%2C%22insights.contributor_part_1_dimension_value_pair%22%5D%2C%22type%22%3A%22looker_scatter%22%2C%22defaults_version%22%3A1%2C%22hidden_points_if_no%22%3A%5B%22contributer_params.meets_min_abs_relative_unexpected_difference%22%5D%7D"
    }
    link: {
      label: "next level only"
      url: "https://looker.thekitchentable.gccbianortham.joonix.net/explore/kevmccarthy_sandbox/insights?fields=insights.contributor_part_1_dimension,insights.contributor_part_1_value,insights.count,insights.total_relative_difference,all_insights_explore_cross_view_refererences.percent_of_grand_total,insights.total_relative_unexpected_difference,insights.contributor_part_1_dimension_value_pair,contributer_params.meets_min_abs_relative_unexpected_difference,insights.contribution_string_concat&f[insights.contributor_array_length]={{contributor_array_length | plus: 1 }}&f[contributer_params.min_abs_relative_unexpected_difference]=0.1&f[all_insights_explore_cross_view_refererences.percent_of_grand_total]=%3E0.001&f[insights.contributor_part_1_value]=&f[insights.contributor_part_1_dimension]=&f[insights.contribution_string_concat]=%25{{contribution_string_concat | append: ';' | url_encode}}%25&sorts=all_insights_explore_cross_view_refererences.percent_of_grand_total+desc&limit=5000&column_limit=50&vis=%7B%22x_axis_gridlines%22%3Afalse%2C%22y_axis_gridlines%22%3Atrue%2C%22show_view_names%22%3Afalse%2C%22show_y_axis_labels%22%3Atrue%2C%22show_y_axis_ticks%22%3Atrue%2C%22y_axis_tick_density%22%3A%22default%22%2C%22y_axis_tick_density_custom%22%3A5%2C%22show_x_axis_label%22%3Atrue%2C%22show_x_axis_ticks%22%3Atrue%2C%22y_axis_scale_mode%22%3A%22linear%22%2C%22x_axis_reversed%22%3Afalse%2C%22y_axis_reversed%22%3Afalse%2C%22plot_size_by_field%22%3Afalse%2C%22trellis%22%3A%22%22%2C%22stacking%22%3A%22%22%2C%22limit_displayed_rows%22%3Atrue%2C%22legend_position%22%3A%22center%22%2C%22point_style%22%3A%22circle%22%2C%22show_value_labels%22%3Atrue%2C%22label_density%22%3A25%2C%22x_axis_scale%22%3A%22linear%22%2C%22y_axis_combined%22%3Atrue%2C%22show_null_points%22%3Afalse%2C%22y_axes%22%3A%5B%7B%22label%22%3A%22Performance+vs+Population%22%2C%22orientation%22%3A%22top%22%2C%22series%22%3A%5B%7B%22axisId%22%3A%22insights.total_relative_unexpected_difference%22%2C%22id%22%3A%22insights.total_relative_unexpected_difference%22%2C%22name%22%3A%22Total+Relative+Unexpected+Difference%22%7D%5D%2C%22showLabels%22%3Atrue%2C%22showValues%22%3Atrue%2C%22maxValue%22%3A1%2C%22minValue%22%3A-1%2C%22valueFormat%22%3A%220%25%22%2C%22unpinAxis%22%3Afalse%2C%22tickDensity%22%3A%22default%22%2C%22tickDensityCustom%22%3A5%2C%22type%22%3A%22linear%22%7D%5D%2C%22size_by_field%22%3A%22%22%2C%22x_axis_zoom%22%3Atrue%2C%22y_axis_zoom%22%3Atrue%2C%22limit_displayed_rows_values%22%3A%7B%22show_hide%22%3A%22show%22%2C%22first_last%22%3A%22first%22%2C%22num_rows%22%3A%22500%22%7D%2C%22hide_legend%22%3Afalse%2C%22font_size%22%3A%2210%22%2C%22series_types%22%3A%7B%22insights.total_relative_unexpected_difference%22%3A%22column%22%7D%2C%22series_colors%22%3A%7B%22reference_0%22%3A%22%23000000%22%7D%2C%22series_labels%22%3A%7B%22reference_line_all%22%3A%22ALL%22%7D%2C%22series_point_styles%22%3A%7B%22reference_0%22%3A%22auto%22%7D%2C%22reference_lines%22%3A%5B%5D%2C%22trend_lines%22%3A%5B%5D%2C%22swap_axes%22%3Atrue%2C%22cluster_points%22%3Afalse%2C%22quadrants_enabled%22%3Afalse%2C%22quadrant_properties%22%3A%7B%220%22%3A%7B%22color%22%3A%22%22%2C%22label%22%3A%22Quadrant+1%22%7D%2C%221%22%3A%7B%22color%22%3A%22%22%2C%22label%22%3A%22Quadrant+2%22%7D%2C%222%22%3A%7B%22color%22%3A%22%22%2C%22label%22%3A%22Quadrant+3%22%7D%2C%223%22%3A%7B%22color%22%3A%22%22%2C%22label%22%3A%22Quadrant+4%22%7D%7D%2C%22custom_quadrant_point_x%22%3A5%2C%22custom_quadrant_point_y%22%3A5%2C%22custom_x_column%22%3A%22all_insights_explore_cross_view_refererences.percent_of_grand_total%22%2C%22custom_y_column%22%3A%22insights.total_relative_unexpected_difference%22%2C%22custom_value_label_column%22%3A%22insights.contribution_string_concat%22%2C%22advanced_vis_config%22%3A%22%7Bchart%3A%7B%7D%2Cseries%3A%5B%7Bname%3A%27Total+Relative+Difference%27%7D%2C%7Bname%3A%27Percent+of+Grand+Total%27%7D%5D%7D%22%2C%22ordering%22%3A%22none%22%2C%22show_null_labels%22%3Afalse%2C%22show_totals_labels%22%3Afalse%2C%22show_silhouette%22%3Afalse%2C%22totals_color%22%3A%22%23808080%22%2C%22show_row_numbers%22%3Atrue%2C%22transpose%22%3Afalse%2C%22truncate_text%22%3Atrue%2C%22hide_totals%22%3Afalse%2C%22hide_row_totals%22%3Afalse%2C%22size_to_fit%22%3Atrue%2C%22table_theme%22%3A%22white%22%2C%22enable_conditional_formatting%22%3Atrue%2C%22header_text_alignment%22%3A%22left%22%2C%22header_font_size%22%3A%2212%22%2C%22rows_font_size%22%3A%2212%22%2C%22conditional_formatting_include_totals%22%3Afalse%2C%22conditional_formatting_include_nulls%22%3Afalse%2C%22show_sql_query_menu_options%22%3Afalse%2C%22show_totals%22%3Atrue%2C%22show_row_totals%22%3Atrue%2C%22truncate_header%22%3Afalse%2C%22minimum_column_width%22%3A75%2C%22series_cell_visualizations%22%3A%7B%22insights.total_relative_difference%22%3A%7B%22is_active%22%3Atrue%2C%22palette%22%3A%7B%22palette_id%22%3A%227b654251-b6d2-b98c-a88f-92ca3d82aa47%22%2C%22collection_id%22%3A%227c56cc21-66e4-41c9-81ce-a60e1c3967b2%22%2C%22custom_colors%22%3A%5B%22%231a73e8%22%2C%22%231a73e8%22%5D%7D%7D%2C%22all_insights_explore_cross_view_refererences.percent_of_grand_total%22%3A%7B%22is_active%22%3Atrue%2C%22palette%22%3A%7B%22palette_id%22%3A%227be0c0fa-6523-6ae3-3b07-aa4bba9a7dc9%22%2C%22collection_id%22%3A%227c56cc21-66e4-41c9-81ce-a60e1c3967b2%22%2C%22custom_colors%22%3A%5B%22%233395ff%22%2C%22%233395ff%22%5D%7D%7D%7D%2C%22conditional_formatting%22%3A%5B%7B%22type%22%3A%22greater+than%22%2C%22value%22%3A0%2C%22background_color%22%3A%22%237CB342%22%2C%22font_color%22%3A%22%237CB342%22%2C%22color_application%22%3A%7B%22collection_id%22%3A%227c56cc21-66e4-41c9-81ce-a60e1c3967b2%22%2C%22palette_id%22%3A%224a00499b-c0fe-4b15-a304-4083c07ff4c4%22%2C%22options%22%3A%7B%22constraints%22%3A%7B%22min%22%3A%7B%22type%22%3A%22minimum%22%7D%2C%22mid%22%3A%7B%22type%22%3A%22number%22%2C%22value%22%3A0%7D%2C%22max%22%3A%7B%22type%22%3A%22maximum%22%7D%7D%2C%22mirror%22%3Atrue%2C%22reverse%22%3Afalse%2C%22stepped%22%3Afalse%7D%7D%2C%22bold%22%3Afalse%2C%22italic%22%3Afalse%2C%22strikethrough%22%3Afalse%2C%22fields%22%3A%5B%22insights.total_relative_difference%22%5D%7D%5D%2C%22series_value_format%22%3A%7B%7D%2C%22hidden_pivots%22%3A%7B%7D%2C%22hidden_fields%22%3A%5B%22insights.count%22%2C%22insights.total_relative_difference%22%2C%22insights.contributor_part_1_dimension%22%2C%22insights.contributor_part_1_value%22%2C%22insights.contributor_part_1_dimension_value_pair%22%5D%2C%22type%22%3A%22looker_scatter%22%2C%22defaults_version%22%3A1%2C%22hidden_points_if_no%22%3A%5B%22contributer_params.meets_min_abs_relative_unexpected_difference%22%5D%7D"
    }
    # html:  <a href = "https://looker.thekitchentable.gccbianortham.joonix.net/explore/kevmccarthy_sandbox/insights?fields=insights.contributor_part_1_dimension,insights.contributor_part_1_value,insights.count,insights.total_relative_difference,all_insights_explore_cross_view_refererences.percent_of_grand_total,insights.total_relative_unexpected_difference,insights.contributor_part_1_dimension_value_pair,contributer_params.meets_min_abs_relative_unexpected_difference,insights.contribution_string_concat&f[insights.contributor_array_length]=&f[contributer_params.min_abs_relative_unexpected_difference]=0.1&f[all_insights_explore_cross_view_refererences.percent_of_grand_total]=%3E0.001&f[insights.contributor_part_1_value]=&f[insights.contributor_part_1_dimension]=&f[insights.contributor_part_1_dimension_value_pair]=%25category%5E_name%3DCANADIAN+WHISKIES%25&sorts=all_insights_explore_cross_view_refererences.percent_of_grand_total+desc&limit=5000&column_limit=50&vis=%7B%22x_axis_gridlines%22%3Afalse%2C%22y_axis_gridlines%22%3Atrue%2C%22show_view_names%22%3Afalse%2C%22show_y_axis_labels%22%3Atrue%2C%22show_y_axis_ticks%22%3Atrue%2C%22y_axis_tick_density%22%3A%22default%22%2C%22y_axis_tick_density_custom%22%3A5%2C%22show_x_axis_label%22%3Atrue%2C%22show_x_axis_ticks%22%3Atrue%2C%22y_axis_scale_mode%22%3A%22linear%22%2C%22x_axis_reversed%22%3Afalse%2C%22y_axis_reversed%22%3Afalse%2C%22plot_size_by_field%22%3Afalse%2C%22trellis%22%3A%22%22%2C%22stacking%22%3A%22%22%2C%22limit_displayed_rows%22%3Atrue%2C%22legend_position%22%3A%22center%22%2C%22point_style%22%3A%22circle%22%2C%22show_value_labels%22%3Atrue%2C%22label_density%22%3A25%2C%22x_axis_scale%22%3A%22linear%22%2C%22y_axis_combined%22%3Atrue%2C%22show_null_points%22%3Afalse%2C%22y_axes%22%3A%5B%7B%22label%22%3A%22Performance+vs+Population%22%2C%22orientation%22%3A%22top%22%2C%22series%22%3A%5B%7B%22axisId%22%3A%22insights.total_relative_unexpected_difference%22%2C%22id%22%3A%22insights.total_relative_unexpected_difference%22%2C%22name%22%3A%22Total+Relative+Unexpected+Difference%22%7D%5D%2C%22showLabels%22%3Atrue%2C%22showValues%22%3Atrue%2C%22maxValue%22%3A1%2C%22minValue%22%3A-1%2C%22valueFormat%22%3A%220%25%22%2C%22unpinAxis%22%3Afalse%2C%22tickDensity%22%3A%22default%22%2C%22tickDensityCustom%22%3A5%2C%22type%22%3A%22linear%22%7D%5D%2C%22size_by_field%22%3A%22%22%2C%22x_axis_zoom%22%3Atrue%2C%22y_axis_zoom%22%3Atrue%2C%22limit_displayed_rows_values%22%3A%7B%22show_hide%22%3A%22show%22%2C%22first_last%22%3A%22first%22%2C%22num_rows%22%3A%22500%22%7D%2C%22hide_legend%22%3Afalse%2C%22font_size%22%3A%2210%22%2C%22series_types%22%3A%7B%22insights.total_relative_unexpected_difference%22%3A%22column%22%7D%2C%22series_colors%22%3A%7B%22reference_0%22%3A%22%23000000%22%7D%2C%22series_labels%22%3A%7B%22reference_line_all%22%3A%22ALL%22%7D%2C%22series_point_styles%22%3A%7B%22reference_0%22%3A%22auto%22%7D%2C%22reference_lines%22%3A%5B%5D%2C%22trend_lines%22%3A%5B%5D%2C%22swap_axes%22%3Atrue%2C%22cluster_points%22%3Afalse%2C%22quadrants_enabled%22%3Afalse%2C%22quadrant_properties%22%3A%7B%220%22%3A%7B%22color%22%3A%22%22%2C%22label%22%3A%22Quadrant+1%22%7D%2C%221%22%3A%7B%22color%22%3A%22%22%2C%22label%22%3A%22Quadrant+2%22%7D%2C%222%22%3A%7B%22color%22%3A%22%22%2C%22label%22%3A%22Quadrant+3%22%7D%2C%223%22%3A%7B%22color%22%3A%22%22%2C%22label%22%3A%22Quadrant+4%22%7D%7D%2C%22custom_quadrant_point_x%22%3A5%2C%22custom_quadrant_point_y%22%3A5%2C%22custom_x_column%22%3A%22all_insights_explore_cross_view_refererences.percent_of_grand_total%22%2C%22custom_y_column%22%3A%22insights.total_relative_unexpected_difference%22%2C%22custom_value_label_column%22%3A%22insights.contribution_string_concat%22%2C%22advanced_vis_config%22%3A%22%7Bchart%3A%7B%7D%2Cseries%3A%5B%7Bname%3A%27Total+Relative+Difference%27%7D%2C%7Bname%3A%27Percent+of+Grand+Total%27%7D%5D%7D%22%2C%22ordering%22%3A%22none%22%2C%22show_null_labels%22%3Afalse%2C%22show_totals_labels%22%3Afalse%2C%22show_silhouette%22%3Afalse%2C%22totals_color%22%3A%22%23808080%22%2C%22show_row_numbers%22%3Atrue%2C%22transpose%22%3Afalse%2C%22truncate_text%22%3Atrue%2C%22hide_totals%22%3Afalse%2C%22hide_row_totals%22%3Afalse%2C%22size_to_fit%22%3Atrue%2C%22table_theme%22%3A%22white%22%2C%22enable_conditional_formatting%22%3Atrue%2C%22header_text_alignment%22%3A%22left%22%2C%22header_font_size%22%3A%2212%22%2C%22rows_font_size%22%3A%2212%22%2C%22conditional_formatting_include_totals%22%3Afalse%2C%22conditional_formatting_include_nulls%22%3Afalse%2C%22show_sql_query_menu_options%22%3Afalse%2C%22show_totals%22%3Atrue%2C%22show_row_totals%22%3Atrue%2C%22truncate_header%22%3Afalse%2C%22minimum_column_width%22%3A75%2C%22series_cell_visualizations%22%3A%7B%22insights.total_relative_difference%22%3A%7B%22is_active%22%3Atrue%2C%22palette%22%3A%7B%22palette_id%22%3A%227b654251-b6d2-b98c-a88f-92ca3d82aa47%22%2C%22collection_id%22%3A%227c56cc21-66e4-41c9-81ce-a60e1c3967b2%22%2C%22custom_colors%22%3A%5B%22%231a73e8%22%2C%22%231a73e8%22%5D%7D%7D%2C%22all_insights_explore_cross_view_refererences.percent_of_grand_total%22%3A%7B%22is_active%22%3Atrue%2C%22palette%22%3A%7B%22palette_id%22%3A%227be0c0fa-6523-6ae3-3b07-aa4bba9a7dc9%22%2C%22collection_id%22%3A%227c56cc21-66e4-41c9-81ce-a60e1c3967b2%22%2C%22custom_colors%22%3A%5B%22%233395ff%22%2C%22%233395ff%22%5D%7D%7D%7D%2C%22conditional_formatting%22%3A%5B%7B%22type%22%3A%22greater+than%22%2C%22value%22%3A0%2C%22background_color%22%3A%22%237CB342%22%2C%22font_color%22%3A%22%237CB342%22%2C%22color_application%22%3A%7B%22collection_id%22%3A%227c56cc21-66e4-41c9-81ce-a60e1c3967b2%22%2C%22palette_id%22%3A%224a00499b-c0fe-4b15-a304-4083c07ff4c4%22%2C%22options%22%3A%7B%22constraints%22%3A%7B%22min%22%3A%7B%22type%22%3A%22minimum%22%7D%2C%22mid%22%3A%7B%22type%22%3A%22number%22%2C%22value%22%3A0%7D%2C%22max%22%3A%7B%22type%22%3A%22maximum%22%7D%7D%2C%22mirror%22%3Atrue%2C%22reverse%22%3Afalse%2C%22stepped%22%3Afalse%7D%7D%2C%22bold%22%3Afalse%2C%22italic%22%3Afalse%2C%22strikethrough%22%3Afalse%2C%22fields%22%3A%5B%22insights.total_relative_difference%22%5D%7D%5D%2C%22series_value_format%22%3A%7B%7D%2C%22hidden_pivots%22%3A%7B%7D%2C%22hidden_fields%22%3A%5B%22insights.count%22%2C%22insights.total_relative_difference%22%2C%22insights.contributor_part_1_dimension%22%2C%22insights.contributor_part_1_value%22%2C%22insights.contributor_part_1_dimension_value_pair%22%5D%2C%22type%22%3A%22looker_scatter%22%2C%22defaults_version%22%3A1%2C%22hidden_points_if_no%22%3A%5B%22contributer_params.meets_min_abs_relative_unexpected_difference%22%5D%7D&filter_config=%7B%22insights.contributor_array_length%22%3A%5B%7B%22type%22%3A%22%3D%22%2C%22values%22%3A%5B%7B%22constant%22%3A%22%22%7D%2C%7B%7D%5D%2C%22id%22%3A6%7D%5D%2C%22contributer_params.min_abs_relative_unexpected_difference%22%3A%5B%7B%22type%22%3A%22%3D%22%2C%22values%22%3A%5B%7B%22constant%22%3A%220.1%22%7D%2C%7B%7D%5D%2C%22id%22%3A7%7D%5D%2C%22all_insights_explore_cross_view_refererences.percent_of_grand_total%22%3A%5B%7B%22type%22%3A%22%5Cu003e%22%2C%22values%22%3A%5B%7B%22constant%22%3A%220.001%22%7D%2C%7B%7D%5D%2C%22id%22%3A8%7D%5D%2C%22insights.contributor_part_1_value%22%3A%5B%7B%22type%22%3A%22%3D%22%2C%22values%22%3A%5B%7B%22constant%22%3A%22%22%7D%2C%7B%7D%5D%2C%22id%22%3A9%7D%5D%2C%22insights.contributor_part_1_dimension%22%3A%5B%7B%22type%22%3A%22%3D%22%2C%22values%22%3A%5B%7B%22constant%22%3A%22%22%7D%2C%7B%7D%5D%2C%22id%22%3A10%7D%5D%2C%22insights.contributor_part_1_dimension_value_pair%22%3A%5B%7B%22type%22%3A%22contains%22%2C%22values%22%3A%5B%7B%22constant%22%3A%22category_name%3DCANADIAN+WHISKIES%22%7D%2C%7B%7D%5D%2C%22id%22%3A11%7D%5D%2C%22__%21internal%21__%22%3A%5B%22OR%22%2C%5B%5B%22AND%22%2C%5B%5B%22FILTER%22%2C%7B%22field%22%3A%22insights.contributor_array_length%22%2C%22value%22%3A%22%22%2C%22type%22%3A%22%3D%22%7D%5D%2C%5B%22FILTER%22%2C%7B%22field%22%3A%22contributer_params.min_abs_relative_unexpected_difference%22%2C%22value%22%3A%220.1%22%2C%22type%22%3A%22%3D%22%7D%5D%2C%5B%22FILTER%22%2C%7B%22field%22%3A%22all_insights_explore_cross_view_refererences.percent_of_grand_total%22%2C%22value%22%3A%22%5Cu003e0.001%22%2C%22type%22%3A%22%5Cu003e%22%7D%5D%2C%5B%22FILTER%22%2C%7B%22field%22%3A%22insights.contributor_part_1_value%22%2C%22value%22%3A%22%22%2C%22type%22%3A%22match%22%7D%5D%2C%5B%22FILTER%22%2C%7B%22field%22%3A%22insights.contributor_part_1_dimension%22%2C%22value%22%3A%22%22%2C%22type%22%3A%22match%22%7D%5D%2C%5B%22FILTER%22%2C%7B%22field%22%3A%22insights.contributor_part_1_dimension_value_pair%22%2C%22value%22%3A%22%25category%5E_name%3DCANADIAN+WHISKIES%25%22%2C%22type%22%3A%22contains%22%7D%5D%5D%5D%5D%5D%7D&dynamic_fields=%5B%7B%22category%22%3A%22table_calculation%22%2C%22expression%22%3A%22concat%28%24%7Binsights.contributor_part_1_dimension%7D%2C%24%7Binsights.contributor_part_1_value%7D%29%22%2C%22label%22%3A%22t%22%2C%22value_format%22%3Anull%2C%22value_format_name%22%3Anull%2C%22_kind_hint%22%3A%22dimension%22%2C%22table_calculation%22%3A%22t%22%2C%22_type_hint%22%3A%22string%22%2C%22is_disabled%22%3Atrue%7D%5D&origin=share-expanded">link</a>;;
  }


  measure: total_unexpected_difference {
    type: sum
    sql: ${unexpected_difference} ;;
    value_format_name: decimal_0
  }
  measure: total_difference {
    type: sum
    sql: ${difference} ;;
    value_format_name: decimal_0
  }

  measure: unexpected_difference_positive {
    group_label: "special chart support"
    type: number
    sql: case when ${total_unexpected_difference}>0 then ${total_unexpected_difference} else null end ;;
  }
  measure: unexpected_difference_loss {
    group_label: "special chart support"
    type: number
    sql: case when ${total_unexpected_difference}>0 then null else -1*${total_unexpected_difference} end ;;
  }
  measure: unexpected_difference_loss_as_negative {
    group_label: "special chart support"
    type: number
    sql: case when ${total_unexpected_difference}>0 then null else ${total_unexpected_difference} end ;;
  }
  measure: expected_difference_base {
    # type: sum
    # sql: ${difference}-${unexpected_difference} ;;
    type: number
    sql: case when ${total_unexpected_difference}>0 then ${total_expected_difference} else ${total_expected_difference}+${total_unexpected_difference} end ;;
  }
  measure: total_expected_difference {
    description: "aka ambient difference - the difference that occurred in population (less this group)"
    type: sum
    sql: ${difference}-${unexpected_difference} ;;
  }
  # measure: unexpected_difference_addon {
  #   # type: sum
  #   # sql: ${difference}-${unexpected_difference} ;;
  #   type: number
  #   sql: case when ${total_unexpected_difference}>0 then ${total_expected_difference} else -1*${unexpected_difference_loss} end ;;
  # }

## link back to raw data explore
  measure: link_back_to_raw_explore {
    type: count
    link: {
      label: "link_1"
      # url: "insights.contributor_part_1_dimension_value_pair"
      # url: "https://looker.thekitchentable.gccbianortham.joonix.net/explore/kevmccarthy_sandbox/iowa_liquor_sales_sales?fields=iowa_liquor_sales_sales.vendor_name,iowa_liquor_sales_sales.count&f[iowa_liquor_sales_sales.vendor_name]=DIAGEO+AMERICAS"
      url: "https://looker.thekitchentable.gccbianortham.joonix.net/explore/kevmccarthy_sandbox/iowa_liquor_sales_sales?fields={{contributor_part_1_dimension | prepend: 'iowa_liquor_sales_sales.'}}"
    }
    link: {
      label: "link_2"
      url: "https://looker.thekitchentable.gccbianortham.joonix.net/explore/kevmccarthy_sandbox/iowa_liquor_sales_sales?
      fields=iowa_liquor_sales_sales.count,
      {{contributor_part_1_dimension | prepend: 'iowa_liquor_sales_sales.'}},iowa_liquor_sales_sales.sale_date_month
      &pivots={{contributor_part_1_dimension | prepend: 'iowa_liquor_sales_sales.'}}
      &fill_fields=iowa_liquor_sales_sales.sale_date_month
      &sorts=iowa_liquor_sales_sales.sale_date_month+desc
      &limit=5000
      &column_limit=50&vis=%7B%22x_axis_gridlines%22%3Afalse%2C%22y_axis_gridlines%22%3Atrue%2C%22show_view_names%22%3Afalse%2C%22show_y_axis_labels%22%3Atrue%2C%22show_y_axis_ticks%22%3Atrue%2C%22y_axis_tick_density%22%3A%22default%22%2C%22y_axis_tick_density_custom%22%3A5%2C%22show_x_axis_label%22%3Atrue%2C%22show_x_axis_ticks%22%3Atrue%2C%22y_axis_scale_mode%22%3A%22linear%22%2C%22x_axis_reversed%22%3Afalse%2C%22y_axis_reversed%22%3Afalse%2C%22plot_size_by_field%22%3Afalse%2C%22trellis%22%3A%22%22%2C%22stacking%22%3A%22%22%2C%22limit_displayed_rows%22%3Afalse%2C%22legend_position%22%3A%22center%22%2C%22point_style%22%3A%22none%22%2C%22show_value_labels%22%3Afalse%2C%22label_density%22%3A25%2C%22x_axis_scale%22%3A%22auto%22%2C%22y_axis_combined%22%3Atrue%2C%22show_null_points%22%3Atrue%2C%22interpolation%22%3A%22linear%22%2C%22type%22%3A%22looker_line%22%2C%22ordering%22%3A%22none%22%2C%22show_null_labels%22%3Afalse%2C%22show_totals_labels%22%3Afalse%2C%22show_silhouette%22%3Afalse%2C%22totals_color%22%3A%22%23808080%22%2C%22defaults_version%22%3A1%2C%22hidden_pivots%22%3A%7B%7D%2C%22series_types%22%3A%7B%7D%7D&filter_config=%7B%7D
      &dynamic_fields=%5B%7B%22category%22%3A%22dimension%22%2C%22description%22%3A%22%22%2C%22label%22%3A%22
      {{contributor_part_1_dimension }}%22%2C%22value_format%22%3Anull%2C%22value_format_name%22%3Anull%2C%22calculation_type%22%3A%22group_by%22%2C%22dimension%22%3A%22
      {{contributor_part_1_dimension }}%22%2C%22args%22%3A%5B%22
      {{contributor_part_1_dimension | prepend: 'iowa_liquor_sales_sales.'}}%22%2C%5B%7B%22label%22%3A%22Selected+Group%22%2C%22filter%22%3A%22
      {{contributor_part_1_value}}22%7D%5D%2C%22Other%22%5D%2C%22_kind_hint%22%3A%22dimension%22%2C%22_type_hint%22%3A%22string%22%7D%5D&origin=share-expanded"
    }
    link: {
      # &pivots={{contributor_part_1_dimension | prepend: 'iowa_liquor_sales_sales.'}}
      label: "link_3"
      url:
"https://looker.thekitchentable.gccbianortham.joonix.net/explore/kevmccarthy_sandbox/iowa_liquor_sales_sales
?fields=iowa_liquor_sales_sales.count,
iowa_liquor_sales_sales.sale_date_month
&sorts=iowa_liquor_sales_sales.sale_date_month+desc
&dynamic_fields=%5B%7B%22category%22%3A%22dimension%22%2C%22description%22%3A%22%22%2C%22label%22%3A%22
{{contributor_part_1_dimension._value }}%22%2C%22value_format%22%3Anull%2C%22value_format_name%22%3Anull%2C%22calculation_type%22%3A%22group_by%22%2C%22dimension%22%3A%22
{{contributor_part_1_dimension._value }}%22%2C%22args%22%3A%5B%22
{{contributor_part_1_dimension._value | prepend: 'iowa_liquor_sales_sales.'}}%22%2C%5B%7B%22label%22%3A%22Selected+Group%22%2C%22filter%22%3A%22
{{contributor_part_1_value._value}}22%7D%5D%2C%22Other%22%5D%2C%22_kind_hint%22%3A%22dimension%22%2C%22_type_hint%22%3A%22string%22%7D%5D"
    }
    link: {
      label: "link_4"
      url: "https://looker.thekitchentable.gccbianortham.joonix.net/explore/kevmccarthy_sandbox/iowa_liquor_sales_sales?fields=iowa_liquor_sales_sales.count,selected_group_vs_rest,iowa_liquor_sales_sales.sale_date_month&pivots=selected_group_vs_rest&fill_fields=iowa_liquor_sales_sales.sale_date_month&sorts=selected_group_vs_rest+desc,iowa_liquor_sales_sales.sale_date_month+desc&limit=5000&column_limit=50&vis=%7B%22x_axis_gridlines%22%3Afalse%2C%22y_axis_gridlines%22%3Atrue%2C%22show_view_names%22%3Afalse%2C%22show_y_axis_labels%22%3Atrue%2C%22show_y_axis_ticks%22%3Atrue%2C%22y_axis_tick_density%22%3A%22default%22%2C%22y_axis_tick_density_custom%22%3A5%2C%22show_x_axis_label%22%3Atrue%2C%22show_x_axis_ticks%22%3Atrue%2C%22y_axis_scale_mode%22%3A%22linear%22%2C%22x_axis_reversed%22%3Afalse%2C%22y_axis_reversed%22%3Afalse%2C%22plot_size_by_field%22%3Afalse%2C%22trellis%22%3A%22%22%2C%22stacking%22%3A%22%22%2C%22limit_displayed_rows%22%3Afalse%2C%22legend_position%22%3A%22center%22%2C%22point_style%22%3A%22none%22%2C%22show_value_labels%22%3Afalse%2C%22label_density%22%3A25%2C%22x_axis_scale%22%3A%22auto%22%2C%22y_axis_combined%22%3Atrue%2C%22show_null_points%22%3Atrue%2C%22interpolation%22%3A%22linear%22%2C%22type%22%3A%22looker_line%22%2C%22ordering%22%3A%22none%22%2C%22show_null_labels%22%3Afalse%2C%22show_totals_labels%22%3Afalse%2C%22show_silhouette%22%3Afalse%2C%22totals_color%22%3A%22%23808080%22%2C%22defaults_version%22%3A1%2C%22hidden_pivots%22%3A%7B%7D%2C%22series_types%22%3A%7B%7D%7D&filter_config=%7B%7D&dynamic_fields=%5B%7B%22category%22%3A%22dimension%22%2C%22description%22%3A%22%22%2C%22label%22%3A%22selected_group_vs_rest%22%2C%22value_format%22%3Anull%2C%22value_format_name%22%3Anull%2C%22calculation_type%22%3A%22group_by%22%2C%22dimension%22%3A%22selected_group_vs_rest%22%2C%22args%22%3A%5B%22{{contributor_part_1_dimension._value|prepend:'iowa_liquor_sales_sales.'}}%22%2C%5B%7B%22label%22%3A%22Selected+Group%22%2C%22filter%22%3A%22{{insights.contributor_part_1_value._value}}%22%7D%5D%2C%22Other%22%5D%2C%22_kind_hint%22%3A%22dimension%22%2C%22_type_hint%22%3A%22string%22%7D%5D&origin=share-expanded"
    }
    link: {
      label: "link_5"
      url: "https://looker.thekitchentable.gccbianortham.joonix.net/explore/kevmccarthy_sandbox/iowa_liquor_sales_sales?fields=iowa_liquor_sales_sales.count,iowa_liquor_sales_sales.sale_date_month,selected&pivots=selected&fill_fields=iowa_liquor_sales_sales.sale_date_month&sorts=selected,iowa_liquor_sales_sales.sale_date_month&limit=5000&column_limit=50&vis=%7B%22x_axis_gridlines%22%3Afalse%2C%22y_axis_gridlines%22%3Atrue%2C%22show_view_names%22%3Afalse%2C%22show_y_axis_labels%22%3Atrue%2C%22show_y_axis_ticks%22%3Atrue%2C%22y_axis_tick_density%22%3A%22default%22%2C%22y_axis_tick_density_custom%22%3A5%2C%22show_x_axis_label%22%3Atrue%2C%22show_x_axis_ticks%22%3Atrue%2C%22y_axis_scale_mode%22%3A%22linear%22%2C%22x_axis_reversed%22%3Afalse%2C%22y_axis_reversed%22%3Afalse%2C%22plot_size_by_field%22%3Afalse%2C%22trellis%22%3A%22%22%2C%22stacking%22%3A%22%22%2C%22limit_displayed_rows%22%3Afalse%2C%22legend_position%22%3A%22center%22%2C%22point_style%22%3A%22none%22%2C%22show_value_labels%22%3Afalse%2C%22label_density%22%3A25%2C%22x_axis_scale%22%3A%22auto%22%2C%22y_axis_combined%22%3Atrue%2C%22show_null_points%22%3Atrue%2C%22interpolation%22%3A%22linear%22%2C%22type%22%3A%22looker_line%22%2C%22ordering%22%3A%22none%22%2C%22show_null_labels%22%3Afalse%2C%22show_totals_labels%22%3Afalse%2C%22show_silhouette%22%3Afalse%2C%22totals_color%22%3A%22%23808080%22%2C%22defaults_version%22%3A1%2C%22hidden_pivots%22%3A%7B%7D%2C%22series_types%22%3A%7B%7D%7D&filter_config=%7B%7D&dynamic_fields=%5B%7B%22category%22%3A%22dimension%22%2C%22expression%22%3A%22%24%7B{{contributor_part_1_dimension._value|prepend:'iowa_liquor_sales_sales.'}}%7D%3D%5C%22{{insights.contributor_part_1_value._value}}%5C%22%22%2C%22label%22%3A%22selected%22%2C%22value_format%22%3Anull%2C%22value_format_name%22%3Anull%2C%22dimension%22%3A%22selected%22%2C%22_kind_hint%22%3A%22dimension%22%2C%22_type_hint%22%3A%22yesno%22%7D%5D&origin=share-expanded"
      }


  }

}
view: all_insights {
  extends: [insights]
  derived_table: {
    sql: select * from ${insights_table.SQL_TABLE_NAME}  ;;
  }
}
view: insights_all_row {
  derived_table: {
    sql: select * from ${insights_table.SQL_TABLE_NAME} insights
          where
          (ARRAY_LENGTH(insights.contributors) ) = 1 --one level only
          AND (split((insights.contributors[0]),'=')[safe_offset (0)]) = 'all'
          limit 1
          ;;
  }
  dimension: metric_control {}
  measure: grand_total_control {
    type: max
    sql: ${metric_control} ;;
  }
}

view: l1_insights_explore_cross_view_refererences {
  measure: percent_of_grand_total {
    type: number
    sql: safe_divide(${l1_insights.total_control},${insights_all_row.grand_total_control}) ;;
    value_format_name: percent_1
  }
}

view: all_insights_explore_cross_view_refererences {
  measure: percent_of_grand_total {
    type: number
    sql: safe_divide(${insights.total_control},${insights_all_row.grand_total_control}) ;;
    value_format_name: percent_1
  }
}

view: l1_insights{
  extends: [insights]
  derived_table: {
    sql: select * from ${insights_table.SQL_TABLE_NAME} insights
    where
    (ARRAY_LENGTH(insights.contributors) ) = 1 --one level only
    AND (split((insights.contributors[0]),'=')[safe_offset (0)]) <> 'all'
    ;;
  }
}
view: contributer_params {
  parameter: min_abs_relative_unexpected_difference {
    type: number
  }
  measure: meets_min_abs_relative_unexpected_difference {
    type: yesno
    sql: abs(${insights.total_relative_unexpected_difference})>coalesce({{min_abs_relative_unexpected_difference._parameter_value}},0) ;;
  }
}
# explore: insights {}
explore: insights {
  view_name:insights from:all_insights
  join: insights_all_row {
    type: cross
    relationship: many_to_one
  }
  join: all_insights_explore_cross_view_refererences {
    sql:  ;;
    relationship: one_to_one
  }
  join: contributer_params {
    sql:  ;;
    relationship: one_to_one
  }
}
explore: l1_insights {
  join: insights_all_row {
    type: cross
    relationship: many_to_one
  }
  join: l1_insights_explore_cross_view_refererences {
    sql:  ;;
    relationship: one_to_one
  }
}
