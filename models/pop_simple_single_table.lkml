#downsides: Must pivot on periods ago, else risk incorrectly showing multiple periods together without any warning to user
# connection: "default_bigquery_connection"

# include: "//thelook_ecommerce_autogen_files/basic_updates_to_views/order_items.view.lkml"


# explore: order_items {
#   join: pop_support {
#     type: cross
#     relationship: one_to_one
#   }
#   #consider a sql_always_where to exclude 'future' data that manifests as a result of POP logic
# }

# # we will fan out the data to get extra copies, and we'll offset dates for POP.
# view: pop_support {
#   derived_table: {
#     #could do fancier logic here to allow additional periods, for example
#     sql:
#     select 0 as periods_ago union all
#     select 1 as periods_ago
#     ;;
#   }
# #MUST PIVOT ON THIS FIELD!!!!
#   dimension: periods_ago {
#     type:  number
#   }

# #could also parameterize the periods size (make a param with which to reset 'year' to some other period size)
#   dimension_group: pop_date {
#     type: time
#     timeframes: [date,month,year]
#     sql: date_add(date(${order_items.created_at_raw}), interval ${periods_ago} year) ;;
#   }
# }

# # #3/6
# # include: "//thelook_ecommerce_autogen_files/basic_updates_to_views/users.view.lkml"
# # explore: users {
# #   #problematic approach: join in the existing simple pop_support, which was built upon order_items date field (order items not needed in this explore)
# #   #join:pop_support
# # }

#was working on a dummy dataset...

view: dummy_data_for_pop {
  derived_table: {
    sql: WITH
      digits as (select * from unnest([0,1,2,3,4,5,6,7,8,9]) as digit)
      ,numbers as (select
      -- cast(first_digit.* as string)
      first_digit.digit,
      second_digit.digit as second_digit,
      third_digit.digit as third_digit,
      cast(concat(first_digit.digit,second_digit.digit,third_digit.digit) as integer) as concatted
      from digits first_digit
      cross join digits second_digit
      cross join digits third_digit
      )
      ,dummy_data_for_pop AS (
      select row_number() over() as row_id, timestamp_add('2024-01-01', INTERVAL concatted DAY) as a_time,*
      from numbers
          )
      SELECT *,
          1000+concatted as dummy_sales_count
      FROM dummy_data_for_pop ;;
  }
  measure: count {type: count}
  dimension: row_id {type: number}

  dimension_group: a_time       {             type: time}
  dimension: digit              {hidden: yes  type: number}
  dimension: second_digit       {hidden: yes  type: number}
  dimension: third_digit        {hidden: yes  type: number}
  dimension: concatted          {             type: number}
  dimension: dummy_sales_count  {             type: number}

  measure: sum_sales {type:sum sql:${dummy_sales_count};;}
}

view: +dummy_data_for_pop {
  derived_table: {


    sql:
{% if periods_ago._is_selected %}
    with pop_support as (select * from unnest([0,1]) as periods_ago)
{% endif %}
    select *,
    date_add(date(a_time), INTERVAL
{% if periods_ago._is_selected %}
    periods_ago
{% else %} 0
{% endif %}
    YEAR) as pop_date
    from
    (

${EXTENDED}
    )
    raw_data
{% if periods_ago._is_selected %}
    cross join pop_support
{% endif %}
    ;;
  }
  dimension: periods_ago {}
  dimension_group: pop_date {type:time}
}


explore: dummy_data_for_pop {}
