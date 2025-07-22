connection: "bq_test"

datagroup: every_5_on_rez {
  sql_trigger:select floor(extract(minute from current_timestamp())/5)*5,TIMESTAMP_TRUNC(current_timestamp(), MINUTE)  ;;
}
view: base_for_ndt_change_test {
  derived_table: {
    sql:
    select 'a' as source, 'a1' as id, 1 as value, timestamp_add(current_timestamp(),interval -0 MINUTE) as a_timestamp  --later will add a 'color'
    union all
    select 'a' as source, 'a2' as id, 2 as value, timestamp_add(current_timestamp(),interval -10 MINUTE) as a_timestamp --later will add a 'color'
    union all
    select 'b' as source, 'b3' as id, 3 as value, timestamp_add(current_timestamp(),interval -5 MINUTE) as a_timestamp --later will add a 'color'
    union all
    select 'c' as source, 'c4' as id, 4 as value, timestamp_add(current_timestamp(),interval -1 MINUTE) as a_timestamp --later will add a 'color'
    union all
    select 'd' as source, 'c5' as id, 5 as value, timestamp_add(current_timestamp(),interval -1 MINUTE) as a_timestamp --later will add a 'color'
    ;;
  }
  dimension: source {}
  dimension: id {primary_key:yes}
  dimension: value {type:number}
  dimension_group: a_timestamp {datatype:timestamp type:time timeframes:[raw,time,minute,date] }
  measure: total_value {type:sum sql:${value};;}
}

explore: base_for_ndt_change_test {
persist_with: every_5_on_rez
}

view: test_ndt_where_we_will_manually_delete_rows_and_columns_between_build {
  derived_table: {
    explore_source: base_for_ndt_change_test {
      column: source {}
      column: id {}
      column: total_value {}
      column: a_timestamp_minute {}
    }
    # persist_for: "2 minutes"
    # sql_trigger_value: select floor(extract(minute from current_timestamp())/2)*2,TIMESTAMP_TRUNC(current_timestamp(), MINUTE)  ;;
    datagroup_trigger: every_5_on_rez
    increment_key: "a_timestamp_minute"
    increment_offset: 1
  }
  dimension: source {}
  dimension: id {primary_key:yes}
  dimension: total_value {}
  dimension: a_timestamp_minute {}

}
explore: test_ndt_where_we_will_manually_delete_rows_and_columns_between_build {}
