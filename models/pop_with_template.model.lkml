#copied from simple_pop, and then templatized (KM's 'tiny templates') pop_support view

#downsides: Must pivot on periods ago, else risk incorrectly showing multiple periods together without any warning to user
connection: "default_bigquery_connection"

include: "//thelook_ecommerce_autogen_files/basic_updates_to_views/order_items.view.lkml"


explore: order_items {
  # join: pop_support {
  join: pop_support {
    from: pop_support__order_items_explore
    type: cross
    relationship: one_to_one
  }
  #consider a sql_always_where to exclude 'future' data that manifests as a result of POP logic
}

# we will fan out the data to get extra copies, and we'll offset dates for POP.
view: pop_support {
  extension: required
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

#could also parameterize the periods size (make a param with which to reset 'year' to some other period size)
  dimension_group: pop_date {
    type: time
    timeframes: [date,month,year]
    # sql: date_add(date(${order_items.created_at_raw}), interval ${periods_ago} year) ;;
    sql: UPDATE ME!!!! ;;
  }
}

view: pop_support__order_items_explore {
  extends: [pop_support]
  dimension_group: pop_date {
    sql: date_add(date(${order_items.created_at_raw}), interval ${periods_ago} year) ;;
  }
}

view: pop_support__users_explore {
  extends: [pop_support]
  dimension_group: pop_date {
    sql: date_add(date(${users.created_at_raw}), interval ${periods_ago} year) ;;
  }
}

# #3/6
include: "//thelook_ecommerce_autogen_files/basic_updates_to_views/users.view.lkml"
explore: users {
  #problematic approach: join in the existing simple pop_support, which was built upon order_items date field (order items not needed in this explore)
  #updated approach using templated view instead:
  join: pop_support {
    from: pop_support__users_explore
    type: cross
    relationship: one_to_one
  }
}
