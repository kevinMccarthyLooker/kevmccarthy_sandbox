connection: "sample_bigquery_connection"

include: "/POP_blog/test_runthrough_20250402/orders__pop_blog_test_runthrough_20250402.view.lkml"
include: "/POP_blog/test_runthrough_20250402/users__pop_blog_test_runthrough_20250402.view.lkml"

explore: orders__pop_blog_test_runthrough_20250402 {
  join: users__pop_blog_test_runthrough_20250402 {
    sql_on: ${users__pop_blog_test_runthrough_20250402.id}=${orders__pop_blog_test_runthrough_20250402.user_id} ;;
    relationship: many_to_one
  }
  join: pop_support {
    type: cross
    relationship: one_to_one
  }
}

view: pop_support {
  derived_table: {
    #could do fancier logic here to allow additional periods, for example
    sql:
    select 0 as periods_ago union all
    select 1 as periods_ago
    ;;
  }
#MUST PIVOT ON THIS FIELD!!!!
  dimension: periods_ago {
    type:  number
  }

  dimension_group: pop_date {
    type: time
    timeframes: [date,month,year]
    sql: timestamp(date_add(date(${orders__pop_blog_test_runthrough_20250402.created_at_raw}), interval ${periods_ago} {% parameter period_size %}));;
  }

  parameter: period_size {
    type: unquoted
    allowed_value: {value:"year"    label:"year"}
    allowed_value: {value:"week"    label:"week"}
    allowed_value: {value:"month"   label:"month"}
    allowed_value: {value:"quarter" label:"quarter"}
  }

  measure: max_created {
    type: date
    sql: max(timestamp_trunc(${orders__pop_blog_test_runthrough_20250402.created_at_raw}, {% if pop_support.pop_date_month._is_selected %}MONTH{% elsif pop_support.pop_date_year._is_selected %}YEAR{% else %}DAY{% endif %}));;
  }

  measure: pop_record_count {
    type: count
  }

  query: pop_start {
    dimensions: [pop_support.pop_date_month]
    pivots: [pop_support.periods_ago]
    measures: [pop_support.pop_record_count, pop_support.max_created]
    filters: [pop_support.period_size: "month"]
  }
}

# explore: +orders__pop_blog_test_runthrough_20250402 {
#   join: pop_support {
#     type: cross
#     relationship: one_to_one
#   }
# }
