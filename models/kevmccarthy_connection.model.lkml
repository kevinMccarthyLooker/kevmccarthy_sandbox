connection: "kevmccarthy_bq"
view: incremental_pdt_with_max_age_20250421 {
  derived_table: {
    sql: select * from unnest(GENERATE_DATE_ARRAY('2016-10-05', '2025-12-31')) a_day ;;
    increment_key: "a_day"
    increment_offset: 3
    sql_trigger_value: select current_timestamp() ;;
  }
  dimension: a_day {type:date}

}

explore: incremental_pdt_with_max_age_20250421  {}
