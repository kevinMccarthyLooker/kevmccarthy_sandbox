view: dummy_data_for_pop {
  derived_table: {
sql:WITH digits as (select * from unnest([0,1,2,3,4,5,6,7,8,9]) as digit)
,numbers_0_to_1000 as
(
  select first_digit.digit,second_digit.digit as second_digit,third_digit.digit as third_digit,
  cast(concat(first_digit.digit,second_digit.digit,third_digit.digit) as integer) as concatted
  from digits first_digit
  cross join digits second_digit
  cross join digits third_digit
)
,dummy_data_for_pop AS (select row_number() over() as row_id, timestamp_add('2024-01-01', INTERVAL concatted DAY) as a_time,* from numbers_0_to_1000)
SELECT *,1000+concatted as dummy_sales_count FROM dummy_data_for_pop
;;
  }
  measure:          count               {type: count}
  dimension:        row_id              {type: number}
  dimension_group:  a_time              {             type: time}
  dimension:        digit               {hidden: yes  type: number}
  dimension:        second_digit        {hidden: yes  type: number}
  dimension:        third_digit         {hidden: yes  type: number}
  dimension:        concatted           {             type: number}
  dimension:        dummy_sales_count   {             type: number}
  measure:          sum_sales           {type:sum sql:${dummy_sales_count};;}
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
