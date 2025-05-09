connection: "kevmccarthy_bq"
# connection: "test_postgresql"
# view: incremental_pdt_with_max_age_20250421 {
#   derived_table: {
#     sql: select * from unnest(GENERATE_DATE_ARRAY('2016-10-05', '2025-12-31')) a_day where a_day>date_add(current_date(),interval -1000 day);;
#     # increment_key: "timestamp(a_day)"
#     # increment_offset: 3
#     # sql_trigger_value: select current_timestamp() ;;
#   }
#   dimension: a_day {type:date datatype:date}

# }

# explore: incremental_pdt_with_max_age_20250421  {}


view: is_drill_filter_logic_passed_through_20250423 {
  derived_table: {
    sql:
select 1 as id, 101 as value
union all
select 2 as id, 102 as value
    ;;
  }
  dimension: id {type:number}
  dimension: value {}
  dimension: id_is_1_yesno{
    type: yesno
    sql: ${id}=1 ;;
  }
  measure: sum_value {
    type: sum
    sql: ${value} ;;
  }

  measure: sum_value_for_1 {
    type: sum
    filters: [id: "1"]
    sql: ${value} ;;
    drill_fields: [id.value,sum_value_for_1,type_number_wrapper_test_with_drill,sum_value]
  }
  measure: type_number_wrapper_test_with_drill {
    type: number
    sql: ${sum_value_for_1} ;;
    link: {
      label:"drill"
      url:"{{drill_with_filter_field_helper._link}}"
    }
  }


  measure: drill_with_filter_field_helper {
    type: max
    filters: [id_is_1_yesno: "Yes"]
    sql: 1 ;;
    drill_fields: [id]
  }
}
explore: is_drill_filter_logic_passed_through_20250423 {}

view: order_items_with_hll {
  derived_table: {
    sql:
    select
    user_id,
    HLL_COUNT.INIT(id) AS hll_sketch,
{% assign all_fields_results = 'order_items_with_hll.user_id,order_items_with_hll.filter_field_yesno,order_items_with_hll.hll_field,order_items_with_hll.drill_with_filter_field_helper,order_items_with_hll.hll_based_measure,order_items_with_hll.count_distinct_user_id' | split:','%}
'{% for field in all_fields_results %}{{field}}:{{_filters[field]  | sql_quote | replace: "'","\'"}}{%endfor%}'
'order_items_with_hll.user_id:{{_filters["order_items_with_hll.user_id"]  | sql_quote | replace: "'",""}}; order_items_with_hll.filter_field_yesno:{{_filters["order_items_with_hll.filter_field_yesno"]  | sql_quote | replace: "'",""}}' as all_fields_with_filters_string

    /* filters applied:
     "order_items_with_hll.filter_field_yesno",
  #       # "order_items_with_hll.hll_field",
  #       # "order_items_with_hll.drill_with_filter_field_helper",
  #       # "order_items_with_hll.hll_based_measure",
  #       # "order_items_with_hll.count_distinct_user_id"
    */

    from kevmccarthy.thelook_with_orders_km.order_items
    group by all

    /* filters applied:
    order_items_with_hll.user_id:{{_filters["order_items_with_hll.user_id"]  | sql_quote }}
    order_items_with_hll.filter_field_yesno:{{_filters["order_items_with_hll.filter_field_yesno"]  | sql_quote }}

     "order_items_with_hll.filter_field_yesno",
  #       # "order_items_with_hll.hll_field",
  #       # "order_items_with_hll.drill_with_filter_field_helper",
  #       # "order_items_with_hll.hll_based_measure",
  #       # "order_items_with_hll.count_distinct_user_id"
    */
    ;;
  }
  dimension: all_fields_with_filters_string {

  }
  dimension: user_id {type:number}
  dimension: user_id_mod_2 {
    type: number
    sql: mod(${user_id},2) ;;
  }
  dimension: filter_field_yesno{
    type: yesno
    sql: ${user_id}=1 ;;
  }
  dimension: hll_field {sql:${TABLE}.hll_sketch;;}
  measure: drill_with_filter_field_helper {
    hidden: yes
    type: count
    filters: [filter_field_yesno: "Yes"]
    drill_fields: [user_id]
  }

  measure: hll_based_measure {
    type: number
    sql: HLL_COUNT.MERGE(CASE WHEN ${filter_field_yesno} THEN  ${hll_field} ELSE NULL END);;
    link: {
      label:"drill"
      url:"{{drill_with_filter_field_helper._link}}"
    }

  }

  measure: count_distinct_user_id {
    type: count_distinct
    sql: ${user_id} ;;

  }

  measure: row_results {
    type: number
    sql: max(1) ;;
    html: {{row}} ;;
  }

  # measure: test_filters_liquid {
  #   type: number
  #   sql: 1 ;;
  #   # sql:
  #   # --endoflogic
  #   # 100 /*note*/
  #   # --filters;{% assign x = _filters %}
  #   # --{%for  entry in x%}
  #   # --1
  #   # --{%endfor%}
  #   # {{x['order_items_with_hll.user_id']}}
  #   # ;;
  #   html:
  #   --endoflogic
  #   100 /*note*/
  #   --filters;{% assign x = _filters._fields %}

  #   ;;
  #   # {{x['order_items_with_hll.user_id']}}
  #   # html: end ;;
  # }

  # dimension: filters {
  #   sql:
  #       {{_filters["order_items_with_hll.user_id"]  | sql_quote }}

  #   ;;
  #       # "order_items_with_hll.filter_field_yesno",
  #       # "order_items_with_hll.hll_field",
  #       # "order_items_with_hll.drill_with_filter_field_helper",
  #       # "order_items_with_hll.hll_based_measure",
  #       # "order_items_with_hll.count_distinct_user_id"

  # }

}
explore:order_items_with_hll  {}


view: in_query_with_custom_fields {
  derived_table: {

    sql:
    --{{ in_query_with_custom_fields.user_id._in_query }}

    select * from kevmccarthy.thelook_with_orders_km.order_items
    ;;
  }
  dimension: user_id {}
  measure: count {type:count}

}
explore: in_query_with_custom_fields {}


view: test_hidden_ranker {
  derived_table: {
    sql:  select 1 as id, 'test' as label, 101 as value
union all select 2 as id, 'test2' as label, 102 as value
    ;;
  }
  dimension: id {type:number}
  dimension: label {}
  dimension: value {
    type:number
    html:​;;
  }
  measure: total_value {type:sum sql:${value};;}
}

explore: test_hidden_ranker {}

view: date_test {
  derived_table: {sql:select '2025-01-01 00:00:00' as a_date;;}
  dimension: a_date {
    type: date
    datatype: timestamp
    sql: ${TABLE}.a_date -- {{_dialect._name}}
    ;;

  }
  dimension: a_string {}
  dimension: a_number {}
  measure: a_max{
    type: max
    # sql: 1 ;;
    sql:  1;;
  }
}

explore: date_test {}

view: pop_test {
  derived_table: {sql:select * from unnest(GENERATE_DATE_ARRAY('2016-10-05', '2025-12-31')) a_date;;}
  dimension_group: date_for_pop {
    type: time timeframes: [date,month]
    datatype: date
    sql: ${TABLE}.a_date ;;

  }
  measure: count {type:count}
  # measure: pop {
  #   type: period_over_period
  #   based_on: count
  #   based_on_time: date_for_pop_date
  #   period: month
  #   kind: previous
  # }
}
explore: pop_test_explore {
  from: pop_test
  # view_name: pop_test
}


include: "/**/create_process_for_custom_incremental_PDT_test.lkml"
