connection: "kevmccarthy_bq"

##
# Include basic auto-generated lookml views will use in the example.
include: "//thelook_ecommerce_autogen_files/auto_gen_views/users.view.lkml"
include: "//thelook_ecommerce_autogen_files/auto_gen_views/order_items.view.lkml"
include: "//thelook_ecommerce_autogen_files/auto_gen_views/events.view.lkml"


# Small edits to base views for specific demo of specific challenges
#Lets pretend they don't have Date level detail in order items, only week
view: +order_items {
  dimension_group: created_at {
    type:time
    timeframes: [week,month,year]
  }
}
# add a distinctness based measure
view: +users {
  #can't really use count_distinct directly, cause it's not summmable
  measure: count_distinct_users {
    type: count_distinct
    sql: ${id} ;;
  }
##
# Count distinct handling with hll, approach 1: init in the source table
  # sql_table_name: (select *, hll_count.init(id) as count_distinct_users__hll_init from `kevmccarthy.thelook_with_orders_km.users` group by all) ;; #this might be one way... but starting the hll init and grouping by all at the base table seems bad
  # measure: count_distinct_users_hll {
  #   hidden: yes
  #   type: number
  #   # sql: hll_count.init(${id}) ;;
  #   sql: hll_count.merge_partial(${TABLE}.count_distinct_users__hll_init) ;;
  # }

## Instead, More likely do the init in a measure in the base view.
  measure: count_distinct_users_hll {
    # hidden: yes
    type: number
    sql: hll_count.init(${id}) ;;
    # sql: hll_count.merge_partial(${TABLE}.count_distinct_users__hll_init) ;;
  }
}

##
# Two foundational source explores
explore: order_items {
  join: users {
    sql_on: ${order_items.user_id}=${users.id} ;;
    relationship: many_to_one
  }
}

explore: events {
  join: users {
    sql_on: ${events.user_id}=${users.id} ;;
    relationship: many_to_one
  }
}

##
# Scenario: Customer asked for following:
# - Dimensions:
# Date (in both explores, Lets pretend they don't have Date level detail in order items, only week
# User Country (in both explores),
# Order Status (in Order Items only),
# Browser (in Events only)
# - Metrics
# Order Item Count
# Event Count
# Distinct Users

##
# Step 1: Build pre-aggregate at the requested grain
# - use nulls if field is not available/doesn't come from that explore

view: order_items_data {
  derived_table: {
    explore_source: order_items {

      derived_column: date_date {sql: cast(null as timestamp) ;;}#avoid type clash in union by matching to existing datatype
      column: date_month {field:order_items.created_at_month}

      column: user_country {field:users.country}

      column: order_status {field:order_items.status}
      derived_column: event_browser {sql: string(null) ;;}

      column: order_items_count {field: order_items.count}
      derived_column: events_count {sql: cast(null as int64) ;;}

      column: count_distinct_users_hll {field:users.count_distinct_users_hll}

    }
    #physicalization parameters would go here...
    # datagroup_trigger: #controlls how often the build job should be run (but only checked when the connection's PDT maintenance schedule fires)
    # partition_keys: []
    # cluster_keys: []

    # increment_key: "" # for incremental build... would presmably be the date
    # increment_offset:  # how many days should be deleted and re-built (typically to restate recent days because of potentially late arriving data)
  }
  #fields would go here... if we were using this view directly
}

view: events_data {
  derived_table: {
    explore_source: events {
      column: date_date {field:events.created_at_date}
      column: date_month {field:events.created_at_month}

      column: user_country {field:users.country}
      derived_column: order_status {sql: string(null) ;;}
      column: event_browser {field:events.browser}

      derived_column: order_items_count {sql: cast(null as int64);;}
      column: events_count {field:events.count}

      column: count_distinct_users_hll {field:users.count_distinct_users_hll}

    }
    #physicalization parameters would go here...
  }
}

view: blended_data {
  derived_table: {
    sql:
select date_date,date_month,user_country,order_status,event_browser,order_items_count,events_count,count_distinct_users_hll from ${order_items_data.SQL_TABLE_NAME}
union all
select date_date,date_month,user_country,order_status,event_browser,order_items_count,events_count,count_distinct_users_hll from ${events_data.SQL_TABLE_NAME}
    ;;
    #physicalization parameters would go here...
  }

  dimension: date_date {
    group_label: "Dates"
    type:date
  }
  dimension: date_month {
    group_label: "Dates"
    type:date_month
  }

  dimension: user_country {}
  dimension: order_status {}
  dimension: event_browser {}

  #raw fields that will be re-aggregated into measures
  dimension: order_items_count {hidden:yes}
  dimension: events_count {hidden:yes}

  #measures
  measure: total_order_items_count {
    type: sum
    sql: ${order_items_count} ;;
  }
  measure: total_events_count {
    type: sum
    sql: ${events_count} ;;
  }

  dimension: count_distinct_users_hll {hidden:yes}
  measure: total_count_distinct_users_hll {
    type: number
    sql: hll_count.merge(${count_distinct_users_hll}) ;;
  }
}

explore: blended_data {}
