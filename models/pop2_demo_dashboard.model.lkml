# ###
# # Asumes:
# # # An existing explore (e.g. order_items) based on the view we date field we want to POP
# # # Want to do POP on a field called created_at_date
# # # Date function syntax similar to BQ syntax
# connection: "default_bigquery_connection"
# include: "//thelook_ecommerce_autogen_files/basic_updates_to_views/order_items.view.lkml"
# explore: order_items {}
# ###

# explore: my_explore_with_pop {
#   extends: [order_items]
#   view_name: order_items

#   join: pop_support {
#     relationship: many_to_one
#     sql:cross join (select 0 as periods_ago union all select 1) pop_support;;
#   }
# }

# view: pop_support {
#   dimension: periods_ago {}
#   dimension_group: pop_date {
#     type: time
#     datatype: date
#     timeframes: [date,month,year]
#     sql: date_add(${order_items.created_at_date::date}, interval ${periods_ago} YEAR) ;;

#   }
#   measure: raw_dates_label {
#     type: string
#     sql: concat( min(${order_items.created_at_raw}),'-',max(${order_items.created_at_raw}))  ;;
#   }
#   measure: raw_dates {
#     type: number
#     sql: 1 ;;
#     html: {{raw_dates_label._rendered_value}};;
#   }
#   measure: min_created {
#     type: date
#     sql:  min(${order_items.created_at_raw}) ;;
#   }

#   measure: max_created {
#     type: date
#     sql:  max(${order_items.created_at_raw}) ;;
#   }

# }

# include: "/pop2_demo_dashboard.dashboard.lookml"


###
# Asumes:
# # An existing explore (e.g. order_items) based on the view we date field we want to POP
# # Want to do POP on a field called created_at_date
# # Date function syntax similar to BQ syntax
connection: "default_bigquery_connection"
# include: "//thelook_ecommerce_autogen_files/basic_updates_to_views/order_items.view.lkml"
include: "//thelook_ecommerce_autogen_files/basic_updates_to_views/users.view.lkml"

explore: users {}
###

view: my_explore_with_pop {
  derived_table: {sql:select 1;;}
}
explore: my_explore_with_pop {
  extends: [users]
  join: users {relationship:one_to_one type:cross }

  join: pop_support {
    relationship: many_to_one
    sql:cross join (select 0 as periods_ago union all select 1) pop_support;;
  }
}

view: pop_support {
  dimension: periods_ago {}
  dimension_group: pop_date {
    type: time
    datatype: date
    timeframes: [date,month,year]
    sql: date_add(${users.created_at_date::date}, interval ${periods_ago} YEAR) ;;

  }

  measure: max_created {
    type: date
    sql: max(timestamp_trunc(${users.created_at_raw}, {% if pop_support.pop_date_month._is_selected %}MONTH{% elsif pop_support.pop_date_year._is_selected %}YEAR{% else %}DAY{% endif %}));;
  }
  measure: explore_row_count_for_pop_demo {
    type: number
    sql: count(*) ;;
  }
}

###
# # Asumes:
# # # An existing explore (e.g. order_items) based on the view we date field we want to POP
# # # Want to do POP on a field called created_at_date
# # # Date function syntax similar to BQ syntax
# connection: "default_bigquery_connection"
# # include: "//thelook_ecommerce_autogen_files/basic_updates_to_views/order_items.view.lkml"
# include: "//thelook_ecommerce_autogen_files/basic_updates_to_views/events.view.lkml"

# explore: events {}
# ###

# view: my_explore_with_pop {
#   derived_table: {sql:select 1;;}
# }
# explore: my_explore_with_pop {
#   extends: [events]
#   join: events {relationship:one_to_one type:cross }

#   join: pop_support {
#     relationship: many_to_one
#     sql:cross join (select 0 as periods_ago union all select 1) pop_support;;
#   }
# }

# view: pop_support {
#   dimension: periods_ago {}
#   dimension_group: pop_date {
#     type: time
#     datatype: date
#     timeframes: [date,month,year]
#     sql: date_add(${events.created_at_date::date}, interval ${periods_ago} YEAR) ;;

#   }

#   measure: max_created {

#     type: date
#     sql: max(timestamp_trunc(${events.created_at_raw}, {% if pop_support.pop_date_month._is_selected %}MONTH{% elsif pop_support.pop_date_year._is_selected %}YEAR{% else %}DAY{% endif %}));;
#   }
#   measure: explore_row_count_for_pop_demo {
#     type: number
#     sql: count(*) ;;
#   }
#   measure: test {
#     type: string
#     sql: max('q') ;;
#   }
# }

include: "/pop2_demo_dashboard.dashboard.lookml"
