connection: "sample_bigquery_connection"
view: order_items {sql_table_name: `bigquery-public-data.thelook_ecommerce.order_items`;;measure: count {type: count}dimension: id {type: number}dimension: order_id {type: number}dimension: user_id {type: number}dimension: product_id {type: number}dimension: inventory_item_id {type: number}dimension: status {}dimension_group: created_at {type: time}dimension_group: shipped_at {type: time}dimension_group: delivered_at {type: time}dimension_group: returned_at {type: time}dimension: sale_price {type: number}}
view: +order_items {dimension:primary_key {primary_key:yes sql:${id};;} measure:count {filters: [primary_key: "-NULL"]}}

view: running_fiscal_calendar {
  derived_table: {
    sql:
      WITH order_items AS (SELECT * FROM `bigquery-public-data.thelook_ecommerce.order_items` where created_at>='2020-01-06' and created_at<'2022-07-10')
      ,  running_total AS (select * from unnest(generate_array(0,13*7,7)) as numbers)

      ,running_total_applied as (
      select
      date_diff(date('2020-01-06'),date(TIMESTAMP_TRUNC(order_items.created_at , WEEK(Monday))), day) as day_number_from_all_time_first_day
      ,(FORMAT_TIMESTAMP('%F', TIMESTAMP_TRUNC(order_items.created_at , WEEK(Monday)))) AS order_items_created_at_week
      ,numbers
      ,date_TRUNC(date_add(date(date_TRUNC(order_items.created_at , WEEK(Monday))),interval numbers day), WEEK(Monday)) as created_at_week_for_running_total
      ,*
      ,1 as count
      from order_items cross join running_total
      )
      , final as (
      select
      created_at_week_for_running_total,
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
      ,min(created_at) min_date,max(created_at) as max_date
      from running_total_applied

      group by all
      )
      select *, row_number() over() as row_id from final
      ;;
    }
    dimension: created_at_week_for_running_total  {
      type: date
      datatype: date
      sql: ${TABLE}.created_at_week_for_running_total ;;
    }
    dimension: primary_key {primary_key:yes
      sql:concat(${created_at_week_for_running_total});;
      # sql:${created_at_week_for_running_total};;
      }
dimension: is_original_week {
  type: yesno
  sql: ${created_at_week_for_running_total} =${order_items.created_at_date};;

}
  measure: count {

    type: sum
    sql: 1 ;;
    filters: [is_original_week: "Yes"]
  }



  # dimension: created_at_week_for_running_total {
  #   type: date
  #   datatype: date
  #   sql: ${TABLE}.created_at_week_for_running_total ;;
  # }

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

  dimension: min_date {
    type: date
    sql: ${TABLE}.min_date ;;
  }

  dimension: max_date {
    type: date
    sql: ${TABLE}.max_date ;;
  }
  }

explore: order_items {
  join: running_fiscal_calendar {
    sql_on: ${order_items.created_at_week::date}=${running_fiscal_calendar.created_at_week_for_running_total} ;;
    # relationship: many_to_many
    relationship: one_to_one
  }
}
