###
# Asumes:
# # An existing explore (e.g. order_items) based on the view we date field we want to POP
# # Want to do POP on a field called created_at_date
# # Date function syntax similar to BQ syntax
connection: "default_bigquery_connection"
include: "//thelook_ecommerce_autogen_files/basic_updates_to_views/order_items.view.lkml"
explore: order_items {}
###

explore: +order_items {
  join: pop_support {
    relationship: many_to_one
    sql:cross join (select 0 as periods_ago union all select 1) pop_support;;
  }
}

view: pop_support {
  dimension: periods_ago {}
  dimension_group: pop_date {
    type: time
    timeframes: [date,month,year]
    sql: date_add(${order_items.created_at_date::date}, interval ${periods_ago} YEAR) ;;
  }
}
