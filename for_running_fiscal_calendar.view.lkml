
view: for_running_fiscal_calendar {
  derived_table: {
    sql: WITH order_items AS (SELECT * FROM `bigquery-public-data.thelook_ecommerce.order_items` where created_at>='2020-01-06' and created_at<'2022-07-10')
      ,  running_total AS (select * from unnest(generate_array(0,13*7,7)) as numbers)

      ,running_total_applied as (
      select
      date_diff(date('2020-01-06'),date(TIMESTAMP_TRUNC(order_items.created_at , WEEK(Monday))), day) as day_number_from_all_time_first_day
      ,(FORMAT_TIMESTAMP('%F', TIMESTAMP_TRUNC(order_items.created_at , WEEK(Monday)))) AS order_items_created_at_week
      ,numbers
      ,date_TRUNC(date_add(date(date_TRUNC(order_items.created_at , WEEK(Monday))),interval numbers day), WEEK(Monday)) as created_at2_week
      -- ,
      -- floor(
      -- (date_diff(date('2020-01-06'),date_add(date(TIMESTAMP_TRUNC(order_items.created_at , WEEK(Monday))),interval numbers day),day)+1)/7
      -- )+1 as

      -- ,count(*) as count
      ,*
      ,1 as count
      from order_items cross join running_total

      -- group by all
      -- order by 4
      )
      select
                  (-1*day_number_from_all_time_first_day/7+1)             as overall_week_number
      ,                                            floor(cast(-1*day_number_from_all_time_first_day/7 as int64)/52)     as fiscal_year
      ,(-1*day_number_from_all_time_first_day/7+1)-floor(cast(-1*day_number_from_all_time_first_day/7 as int64)/52)*52  as fiscal_week_of_year
      ,
      case  when (-1*day_number_from_all_time_first_day/7+1)-floor(cast(-1*day_number_from_all_time_first_day/7 as int64)/52)*52 < 14 then 1
            when (-1*day_number_from_all_time_first_day/7+1)-floor(cast(-1*day_number_from_all_time_first_day/7 as int64)/52)*52 < 27 then 2
            when (-1*day_number_from_all_time_first_day/7+1)-floor(cast(-1*day_number_from_all_time_first_day/7 as int64)/52)*52 < 40 then 3
            when (-1*day_number_from_all_time_first_day/7+1)-floor(cast(-1*day_number_from_all_time_first_day/7 as int64)/52)*52 < 53 then 4
      else 5
      end as fiscal_quarter_of_year
      ,
      (-1*day_number_from_all_time_first_day/7+1)-floor(cast(-1*day_number_from_all_time_first_day/7 as int64)/52)*52 -
      case  when (-1*day_number_from_all_time_first_day/7+1)-floor(cast(-1*day_number_from_all_time_first_day/7 as int64)/52)*52 < 14 then 0
            when (-1*day_number_from_all_time_first_day/7+1)-floor(cast(-1*day_number_from_all_time_first_day/7 as int64)/52)*52 < 27 then 13
            when (-1*day_number_from_all_time_first_day/7+1)-floor(cast(-1*day_number_from_all_time_first_day/7 as int64)/52)*52 < 40 then 26
            when (-1*day_number_from_all_time_first_day/7+1)-floor(cast(-1*day_number_from_all_time_first_day/7 as int64)/52)*52 < 53 then 39
      else 52
      end
      as fiscal_quarter_of_year2



      -- case
      --   when (-1*day_number_from_all_time_first_day/7+1)< 52 then
      -- as monhth_number

      ,min(created_at),max(created_at)
      from running_total_applied

      -- where -1*day_number_from_all_time_first_day/7 +1 in (0,13,14,25,26,27,28)
      group by all
      -- select created_at2_week
      -- -- ,date_TRUNC(date(created_at),WEEK(Monday)) as the_date,
      -- ,sum(case when created_at2_week<=date(created_at) then count else null end) as actual, sum(count) as running_total from running_total_applied group by all
      -- order by 1
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: overall_week_number {
    type: number
    sql: ${TABLE}.overall_week_number ;;
  }

  dimension: fiscal_year {
    type: number
    sql: ${TABLE}.fiscal_year ;;
  }

  dimension: fiscal_week_of_year {
    type: number
    sql: ${TABLE}.fiscal_week_of_year ;;
  }

  dimension: fiscal_quarter_of_year {
    type: number
    sql: ${TABLE}.fiscal_quarter_of_year ;;
  }

  dimension: fiscal_quarter_of_year2 {
    type: number
    sql: ${TABLE}.fiscal_quarter_of_year2 ;;
  }

  dimension_group: f0_ {
    type: time
    sql: ${TABLE}.f0_ ;;
  }

  dimension_group: f1_ {
    type: time
    sql: ${TABLE}.f1_ ;;
  }

  set: detail {
    fields: [
        overall_week_number,
  fiscal_year,
  fiscal_week_of_year,
  fiscal_quarter_of_year,
  fiscal_quarter_of_year2,
  f0__time,
  f1__time
    ]
  }
}
