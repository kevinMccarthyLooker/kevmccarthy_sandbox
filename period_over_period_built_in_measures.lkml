
view: order_items_base {
  derived_table: {
    sql: SELECT * FROM `bigquery-public-data.thelook_ecommerce.order_items` ;;
  }

  measure: count {
    type: count
  }

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: product_id {
    type: number
    sql: ${TABLE}.product_id ;;
  }

  dimension: inventory_item_id {
    type: number
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension_group: created_at {
    type: time
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: shipped_at {
    type: time
    sql: ${TABLE}.shipped_at ;;
  }

  dimension_group: delivered_at {
    type: time
    sql: ${TABLE}.delivered_at ;;
  }

  dimension_group: returned_at {
    type: time
    sql: ${TABLE}.returned_at ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

}
view: order_items_with_period_over_period_built_in_measures {
  extends: [order_items_base]
  measure: count_yoy {
    type: period_over_period
    based_on: count
    based_on_time: created_at_date
    period: year
    kind: previous
  }
  measure: order_count_last_year {
    type: period_over_period
    description: "Order count from the previous year"
    based_on:count
    based_on_time: created_at_year
    period: year
    kind: previous
  }
  measure: total_sales {
    type: sum
    sql: ${sale_price} ;;
  }

  measure: sales_mtd {
    type: period_over_period
    based_on: total_sales
    based_on_time: created_at_month

    period: year
  }

  measure: sales_mtd_previous {
    type: period_over_period
    based_on: total_sales
    value_to_date: yes
    based_on_time: created_at_month
    period: year
    kind: previous
  }
  # dimension: is_mdt {
  #   type: yesno
  #   sql: date_trunc(${created_at_date},interval month) = date_trunc(current_date(),interval month) ;;
  # }
}

explore:  order_items_with_period_over_period_built_in_measures {

}
#examples from docs:
# measure: order_count_last_year {
#   type: period_over_period
#   description: "Order count from the previous year"
#   based_on: orders.count
#   based_on_time: orders.created_year
#   period: year
#   kind: previous
# }
# sql_always_having: ${order_items_with_period_over_period_built_in_measures.count} > 0;;
  # sql_always_having:${order_items_with_period_over_period_built_in_measures.sale_price} > 0 /* ttest j havingt */;;
