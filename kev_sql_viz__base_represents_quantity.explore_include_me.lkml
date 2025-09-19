view: kev_sql_viz__base_represents_quantity {
  derived_table: {
    sql:
-- select gender,count(*),sum(sale) from unnest(generate_array(0,100))

WITH order_items_view__order_items_explore AS (SELECT * FROM `bigquery-public-data.thelook_ecommerce.order_items` )
  ,  users AS (SELECT * except(created_at) FROM `bigquery-public-data.thelook_ecommerce.users` )
SELECT *
FROM order_items_view__order_items_explore AS order_items
LEFT JOIN users ON order_items.user_id=users.id

    ;;
  }


  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  # dimension: users_count {
  #   type: number
  #   sql: ${TABLE}.users_count ;;
  # }

  dimension: total_sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }
  measure: sum_order_items_total_sale_price {
    type: sum
    sql:${total_sale_price};;
  }

  dimension: size_compared_to_max {
    type: number
    sql: ${TABLE}.size_compared_to_max ;;
  }

  dimension: value_to_compare_to_version {
    type: number
    sql: ${TABLE}.value_to_compare_to_version ;;
  }
  dimension_group: created_at {
    type: time
  }

  measure: pop {
    type: period_over_period
    based_on: sum_order_items_total_sale_price
    based_on_time: created_at_date
    period: year

  }

}
view: t2 {
  # derived_table: {sql:left join unnest(generate_array(0,100)) as version;;}
  # dimension: a_number {sql:'placeholder';;}
  # dimension: a_number {sql:unnest(generate_array(0,2));;}
  dimension: a_number {sql:t2;;}
}
explore:  kev_sql_viz__base_represents_quantity{
  # join: t2 {sql: left join unnest(generate_array(0,100)) as t2;;}
    # join: t2 {sql: ;; relationship: one_to_one}

  # sql_always_having:
  # 1=1
  # ;;
#   )
# select *
# ,row_number() over() as result_set_row_number
# from x
# left join unnest(generate_array(0,100)) as version
# qualify version <= 100*(kev_sql_viz__base_represents_quantity_sum_order_items_total_sale_price/max(kev_sql_viz__base_represents_quantity_sum_order_items_total_sale_price) over(partition by version))
#   ;;
}

# qualify 100*COALESCE(SUM(order_items.sale_price ), 0)/ max(COALESCE(SUM(order_items.sale_price ), 0)) over(partition by version)>version
