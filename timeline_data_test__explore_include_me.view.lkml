view: timeline_data_test {
  derived_table: {
    sql:
    select
    dates
    ,date_diff( dates,'2020-01-01',day) as day_number_overall
    ,10+rand()*10 as value
    from unnest(generate_date_array('2020-01-01',current_date(),interval 1 day)) as dates
    ;;
  }
  dimension_group: day {type:time datatype:date sql:${TABLE}.dates;;}
  dimension: dates_plus_one {type:date sql:date_add(${day_date},interval 1 day);;}
  dimension: day_number_overall {type:number}
  dimension: value {type:number}
  measure: total_value {type:sum sql:${value};;}
}
explore: timeline_data_test {}
