connection: "default_bigquery_connection"

include: "//thelook_ecommerce_autogen_files/basic_updates_to_views/order_items.view.lkml"

explore: order_items {
  join: pop_support {
    type: cross
    relationship: one_to_one
  }

}

view: pop_support {
  derived_table: {
    sql:
    select 0 as periods_ago union all
    select 1 as periods_ago
    ;;
  }
  dimension: periods_ago {
    type:  number
  }

  dimension_group: pop_date {
    type: time
    timeframes: [date,month,year]
    sql: date_add(date(${order_items.created_at_raw}), interval ${periods_ago} year) ;;
  }

}
