view: test_date_types_for_confluent {
  derived_table: {sql:select 1 as id;;}
  dimension_group: created_at {
    type: time
    sql: ${TABLE}.created_at ;;
  }
  dimension: curr_as_timestamp {
    type: date
    datatype: timestamp
    sql: current_timestamp() ;;
  }
  dimension: curr_as_datetime {
    type: date
    datatype: datetime
    sql: CURRENT_DATETIME() ;;
  }

}
explore: test_date_types_for_confluent {}
