connection: "bq_test"

datagroup: every_5_on_rez {
  sql_trigger:select floor(extract(minute from current_timestamp())/5)*5,TIMESTAMP_TRUNC(current_timestamp(), MINUTE)  ;;
}

view: test_pdt {
  derived_table: {
    sql:  select 2 as id, current_timestamp() ;;
    datagroup_trigger: every_5_on_rez
  }
  dimension: id {}
}
explore: test_pdt {}
