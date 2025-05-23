# include: "//thelook_ecommerce_autogen_files/auto_gen_views/events.view.lkml"

view: events_for_extend {
  derived_table: {
    sql: SELECT * FROM `bigquery-public-data.thelook_ecommerce.events` ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: id {
    type: number
    sql: ${special_table}.id ;;
  }

  dimension: user_id {
    type: number
    sql: ${special_table}.user_id ;;
  }

  dimension: sequence_number {
    type: number
    sql: ${special_table}.sequence_number ;;
  }

  dimension: session_id {
    type: string
    sql: ${special_table}.session_id ;;
  }

  dimension_group: created_at {
    type: time
    sql: ${special_table}.created_at ;;
  }

  dimension: ip_address {
    type: string
    sql: ${special_table}.ip_address ;;
  }

  dimension: city {
    type: string
    sql: ${special_table}.city ;;
  }

  dimension: state {
    type: string
    sql: ${special_table}.state ;;
  }

  dimension: postal_code {
    type: string
    sql: ${special_table}.postal_code ;;
  }

  dimension: browser {
    type: string
    sql: ${special_table}.browser ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${special_table}.traffic_source ;;
  }

  dimension: uri {
    type: string
    sql: ${special_table}.uri ;;
  }

  dimension: event_type {
    type: string
    sql: ${special_table}.event_type ;;
  }

  set: detail {
    fields: [
      id,
      user_id,
      sequence_number,
      session_id,
      created_at_time,
      ip_address,
      city,
      state,
      postal_code,
      browser,
      traffic_source,
      uri,
      event_type
    ]
  }

  ####
  dimension: special_table {sql: events_for_extend ;;}
}

view: events_with_pop_base {
  extends: [events_for_extend]
  dimension: special_table {sql: events_with_pop_base ;;}
  measure: count {label:"updated"}#extending
  measure: min_date {
    type: min
    sql: ${created_at_date} ;;
    html: {{value}} ;;
  }
}
view: events_with_pop_extension__current {
  extends: [events_with_pop_base]
  dimension: special_table {sql: events_with_pop_extension__current ;;}
  # sql_table_name:
  # (select 'current' as period,* from ${EXTENDED} union all select 'prior' as period,* from ${EXTENDED})
  # ;;
  derived_table: {
    sql:
    select 'current' as period,* from (${EXTENDED})
    union all
    select 'prior' as period,* from (${EXTENDED})
    ;;
  }
  dimension: is_this_period {type:yesno sql:case when ${TABLE}.period='current' then true else false end;;}

#all measures with aggregate types... update wrap sql
  measure: count {
    # sql:   case when ${is_this_period} then ${EXTENDED} else null end ;;
    filters: [is_this_period: "Yes"]
  }


  dimension: table_ref {
    sql: {% assign x = "${TABLE}" %}'tabl= {{x}}';;
  }
  measure: min_date {
    # sql: case when ${is_this_period} then ${EXTENDED} else null end;;
    sql:
{% assign original_table = "${TABLE}" | strip%}
--original_table:{{original_table}}
{% assign original_sql = '${EXTENDED}' | strip%}
--original_sql:{{original_sql | split: 'c'|first}}
{% assign updated_sql = original_sql | replace: 'current','xxx' %}
--updated_sql:{{updated_sql}}
'test'
    ;;
# {% assign updated_sql = original_sql | replace: 'events_with','xxx' %}
    # sql: --{% assign x = _field._sql %}
    # 'test'
    # ;;

#     sql:
#     {% assign original_sql = '${EXTENDED}' |prepend: ' |'%}
# --original_sql1:{{original_sql}}
# --original_sql:{{original_sql | replace: '_date' , ''}}
# 'test'
#     ;;
  # sql: case when ${is_this_period} then ${EXTENDED} else null end;;

  }
  measure: min_date_current {
    type: string
    sql:
    {% assign original_table = special_table._sql | strip %}
    --original_table:{{original_table}}
    {% assign original_sql = min_date._sql %}
    'original_sql:{{original_sql}}'
    {% assign updated_sql = original_sql | replace: original_table,"case when period = 'current' then null else 1 end" %}
    'updated_sql:{{updated_sql}}'
    ;;
  }
  measure: min_date_prior {
    type: min
    sql: {{min_date._sql}} ;;
  }

}
