
view: hll_test2 {
  derived_table: {
    sql: with events as (select * EXCEPT(postal_code) from `bigquery-public-data.thelook_ecommerce.events`
      where user_id is not null
      ),

      -- #reference:all fields
      -- id,
      -- user_id,
      -- sequence_number,
      -- session_id,
      -- created_at,
      -- ip_address,
      -- city,
      -- state,
      -- postal_code,
      -- browser,
      -- traffic_source,
      -- uri,
      -- event_type,

      -- #reference:uniqueness of all fields
      --select count(*) --2431520
      -- count(distinct id) as id, -- 2431520 --surrogate key: id
      -- count(distinct created_at) as created_at, -- 2190585 -- nearly unique
      -- count(distinct session_id) as session_id, -- 681742
      -- count(distinct ip_address) as ip_address, -- 681683
      -- count(distinct user_id) as user_id, -- 79966
      -- count(distinct uri) as uri, -- 35530
      -- count(distinct postal_code) as postal_code, -- 17307
      -- count(distinct city) as city, -- 8775
      -- count(distinct state) as state, -- 231
      -- count(distinct sequence_number) as sequence_number, -- 13
      -- count(distinct event_type) as event_type, -- 6
      -- count(distinct browser) as browser, -- 5
      -- count(distinct traffic_source) as traffic_source, -- 5

      -- events_pre_aggregation_row_count_test as (SELECT * FROM events group by all) -- 2431520 --same as count(*)
      -- events_pre_aggregation_row_count_test as (SELECT session_id,sequence_number FROM events group by all) -- 2431520 --same as count(*). This is a natural key
      -- events_pre_aggregation_row_count_test as (SELECT * EXCEPT (id,session_id,sequence_number) FROM events group by all) -- 2431520 --still same as count(*)

      -- events_pre_aggregation_row_count_test as (SELECT * EXCEPT (id,session_id,sequence_number,created_at) FROM events group by all) -- 1939328 --removing created_at eliminated 20%

      -- events_pre_aggregation_row_count_test as (SELECT * EXCEPT (id,session_id,sequence_number,created_at) FROM events group by all) -- 1939328 --removing created_at eliminated 20%

      -- events_pre_aggregation_row_count_test as (SELECT date(created_at) as create_at_date, * EXCEPT (created_at,id,session_id,sequence_number) FROM events group by all) -- 1941374 --date instead of created_at we still got most of the 20% reduction

      -- events_pre_aggregation_row_count_test as (SELECT date(created_at) as create_at_date, * EXCEPT (created_at,id,session_id,sequence_number,user_id,ip_address) FROM events group by all) -- 1925056 --removing user_id and ip_address only provided a small reduction

      -- events_pre_aggregation_row_count_test as (SELECT date(created_at) as create_at_date, * EXCEPT (created_at,id,session_id,sequence_number,user_id,ip_address,uri,city)

      events_pre_aggregation_row_count_test as (SELECT
      -- date(created_at) as create_at_date,
      date_trunc(created_at,MONTH) as created_at_month,
      * EXCEPT (created_at,id,session_id,sequence_number,user_id,ip_address,uri,city)
      ,count(distinct user_id) as actual_user_count
      ,hll_count.init(user_id) as approx_user_count

      ,count(distinct concat(user_id,date(created_at))) as actual_daily_user_count
      ,hll_count.init(concat(user_id,date(created_at))) as approx_daily_user_count
      ,
      FROM events group by all)
      select * from events_pre_aggregation_row_count_test;;
  }

  measure: count {
    label: "table row count"
    type: count
  }

  dimension_group: created_at_month {
    type: time
    timeframes: [month,year]

    sql: ${TABLE}.created_at_month ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: browser {
    type: string
    sql: ${TABLE}.browser ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
  }

  dimension: event_type {
    type: string
    sql: ${TABLE}.event_type ;;
  }

  dimension: actual_user_count {
    type: number
    sql: ${TABLE}.actual_user_count ;;
  }

  dimension: approx_user_count {
    type: string
    sql: ${TABLE}.approx_user_count ;;
  }

  dimension: actual_daily_user_count {
    type: number
    sql: ${TABLE}.actual_daily_user_count ;;
  }

  dimension: approx_daily_user_count {
    type: string
    sql: ${TABLE}.approx_daily_user_count ;;
  }

  measure: count_distinct_users {
    type: number
    sql: hll_count.merge(${approx_user_count}) ;;
  }

  measure: count_type_measure_for_replace_with_merge {
    filters: [browser: "Chrome"]
    type: count_distinct
    sql:${approx_user_count};;
    drill_fields: [traffic_source]
    allow_approximate_optimization: yes
  }

  measure: hll_injected_into_count_distinct {
    required_fields: [count_type_measure_for_replace_with_merge]
    type: number
    sql:
    {% assign sql = count_type_measure_for_replace_with_merge._sql %}
    {% assign updated_sql = sql | replace: 'COUNT(DISTINCT ','hll_count.merge('  %}
    {{updated_sql}};;
    link: {label:"passed drill" url: "{{count_type_measure_for_replace_with_merge._link}}"}
  }
}

explore: hll_test2 {}

# noted that looker has an allow approximate aggregations parameter
#and that i couldn't (yet at least) hack agg awareness to merge automatically
#generated from explore 5/28:

explore: +hll_test2 {
  aggregate_table: rollup__count__count_distinct_users__hll_injected_into_count_distinct {
    query: {
      dimensions: [browser,state]
      measures: [count, count_distinct_users, hll_injected_into_count_distinct]
    }
    materialization: {
      persist_for: "24 hours"
    }
  }
}
