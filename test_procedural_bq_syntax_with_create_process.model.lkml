## 4/11/25
# This was testing a workaround to hack sql_preamble to allow procedural bq
# however, is seems create_process could be used to similar effect, and would raise fewer concerns

connection: "sample_bigquery_connection"

explore: test_procedural_bq_syntax {
# view_name: script_start
  # join: test_data {
  #   type: cross
  # }
  view_name: test_data

  join: script_start {sql:  ;; relationship: one_to_one}
}


view: test_data {
  # sql_table_name: (select xVar as x) ;;
  derived_table: {sql:select xVar as x ;;}

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: x {
    type: number
    sql: ${TABLE}.x ;;
  }

  dimension: xVar_exposed {
    sql: xVar ;;
  }
  dimension: test_plus_1 {
    sql:add_1(101)  ;;
  }
  dimension: test_intermediate_sql {
    sql: intermediate_sql ;;
  }
  dimension: test_intermediate_result {
    sql: intermediate_result ;;
  }

  set: detail {
    fields: [
      x
    ]
  }
}
view: script_start {
  derived_table: {
    # persist_for:"24 hour"
    # persist_for:"-1 hour"
    persist_for:"1 second"
    create_process: {
      sql_step:
            DECLARE xVar FLOAT64;
            DECLARE stringVar STRING;
            DECLARE table_id STRING;
            DECLARE intermediate_sql STRING;
            DECLARE intermediate_result INT64;
            SET xVar = {{_user_attributes['id']}}; -- can set variables based on user attributes
            SET stringVar = {{test_entry._parameter_value}}; -- or parameter choices
            SET table_id = '`thekitchentable.kevmccarthy_sandbox_dataset.user_{{_user_attributes['name'] }}_queries`';
            SET intermediate_sql = concat('select count(*) from ', table_id);
            EXECUTE IMMEDIATE intermediate_sql into intermediate_result;

        --Example Usage: Create UDFs, for example:
        CREATE TEMP FUNCTION add_1(value_to_add_1_to INT64) AS ((value_to_add_1_to + 1));

        --Example Usage: Add a record to a log table before running the main query
        CREATE TABLE IF NOT EXISTS `thekitchentable.kevmccarthy_sandbox_dataset.user_{{_user_attributes['name'] }}_queries`  AS (
        select 'Inital creation of user query log table' as event, current_timestamp() as event_timestamp
        );
        INSERT INTO `thekitchentable.kevmccarthy_sandbox_dataset.user_{{_user_attributes['name'] }}_queries` (
Select concat('user queried explore: {{_explore}}, bq session:',coalesce(@@session_id,'null session_id')) as event, current_timestamp() as event_timestamp
        );

        --Insert the CTE initaition that we overrode
        --Assumes this is the base view or first derived table of explore encountered by in paths
        WITH {{_view._name}} as (
        select xVar, stringVar
        )
        --don't actually necessarily need to build any table.
        -- but for what it's worth, this didn't seem to write anywhere
        select * from {{_view._name}}
        ;
        ;;
    }
  }
  # dimension: pl {sql:'placeholder';;}
  parameter: test_entry {
    type: string
    default_value: "unset"
  }
  dimension: stringVar {sql:stringVar;;}
}




# --;;#commented out end of sql
# }#;; ;;
