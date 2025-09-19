view: orders_partitioned_by_epoch{
  sql_table_name: kevmccarthy.thelook_with_orders_km.orders_partitioned_by_epoch ;;

  dimension: unix_thousand_seconds {type: number}
  dimension: order_id {type: number}
  dimension: user_id {type: number}
  dimension: status {}
  dimension: gender {}
  dimension_group: created_at {type: time}
  dimension_group: returned_at {type: time}
  dimension_group: shipped_at {type: time}
  dimension_group: delivered_at {type: time}
  dimension: num_of_item {type: number}
  measure: count {type: count}

  dimension: unix_thousand_seconds_as_string_for_suggestions {
    type: string
    sql: cast(${unix_thousand_seconds} as string) ;;
  }
  filter: unix_thousand_seconds_filter {
    type: string
    suggest_dimension: unix_thousand_seconds_as_string_for_suggestions
  }
  dimension: selected_suggestion_values_in_sql {
    # hidden: yes # should probably hide
    sql:{% condition unix_thousand_seconds_filter %}/*placeholder*/{% endcondition %};;
  }
  dimension: selected_suggestion_values_in_sql_quotes_removed {
    # hidden: yes # should probably hide
    sql:{{selected_suggestion_values_in_sql._sql | replace: "'",""}};;
  }

  #here's a field for filtering this view.
  #but next, you will want to filter joined views as well.  you could re-use the beloew field's logic but substite a similar partitioned column in the joined view
  dimension: partition_field_meets_selected_criteria {
    # hidden: yes # should probably hide
    #this ends up being bool type, which doesn't isn't quite same as looker yesno but should work
    sql:{{selected_suggestion_values_in_sql_quotes_removed._sql | replace: "/*placeholder*/",'${unix_thousand_seconds}' }};;
  }
}

explore: orders_partitioned_by_epoch {
  sql_always_where:{% if unix_thousand_seconds_filter._is_filtered %}${orders_partitioned_by_epoch.partition_field_meets_selected_criteria}{% endif %};;
}
