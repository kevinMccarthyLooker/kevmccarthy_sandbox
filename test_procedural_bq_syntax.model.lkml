## 4/11/25
# This was testing a workaround to hack sql_preamble to allow procedural bq
# however, is seems create_process could be used to similar effect, and would raise fewer concerns
# But upon investigation, it seems that create_process is a different session
# connection: "sample_bigquery_connection"
connection: "default_bigquery_connection"
explore: test_procedural_bq_syntax {
  #use comments to work around standard looker-generated sql structure
  #This allows procedural language (https://cloud.google.com/bigquery/docs/reference/standard-sql/procedural-language)
  # With procedural language, you can:
  # # Run multiple statements in a sequence, with shared state.
  # # Automate management tasks such as creating or dropping tables.
  # # Implement complex logic using programming constructs such as IF and WHILE.

  sql_preamble:/*;;#;; special comment resets text colors in IDE ;;
  # from: test_data
  # join: v2 {relationship: one_to_one sql:  ;;}
  # from: v2
  view_name: script_start
  # join: test_data {relationship: one_to_one sql: full outer join test_data on 1=1;;}
  join: iowa_liquor_sales_sales {relationship: one_to_one sql: full outer join iowa_liquor_sales_sales on 1=1;;}
  join: script_end {relationship: one_to_one sql: ;;}
  # sql_always_having:1=1;;
  sql_always_having:
  --2
  1=1

  )
  --LIMIT 100000 --consider having a limit to avoid writing TBs of data (at least until more testing completed)
  )
  );


CREATE OR REPLACE MODEL thekitchentable.kevmccarthy_sandbox_dataset.dynamic_contribution_analysis_test
OPTIONS
(
  model_type = 'CONTRIBUTION_ANALYSIS',
  MIN_APRIORI_SUPPORT = 0.001,
  --list all the dimensions that were included
  --NEED TO SOMEHOW MAKE THIS DYNMIC.. know not to select the test field
  dimension_id_cols = [
    'iowa_liquor_sales_sales_bottle_volume_ml',
    'iowa_liquor_sales_sales_bottles_sold',
  -- 'iowa_liquor_sales_sales_category_name',
    'iowa_liquor_sales_sales_pack',
    'iowa_liquor_sales_sales_sale_date_month'
  ],
  is_test_col = 'is_test',
  contribution_metric = 'sum(iowa_liquor_sales_sales_total_sales)'--define the metric including the aggregation
) AS
SELECT case when is_test='Yes' then TRUE else FALSE end as is_test, source_data.* EXCEPT(is_test) FROM `thekitchentable.kevmccarthy_sandbox_dataset.procedural_queries_results_test` as source_data
;
CREATE OR REPLACE TABLE thekitchentable.kevmccarthy_sandbox_dataset.dynamic_insights_test
AS (SELECT
--'still somewhat manually handling fields and filters 4/11/2025' as passed_message
{{script_start.test_entry._parameter_value}} as passed_message
,* FROM ML.GET_INSIGHTS(MODEL thekitchentable.kevmccarthy_sandbox_dataset.dynamic_contribution_analysis_test))
;

select * from((select * from `thekitchentable.kevmccarthy_sandbox_dataset.procedural_queries_results_test`

;;
#end sql_having workaround to write results to a separate table
}


# view: test_data {
#   # sql_table_name: (select xVar as x) ;;
#   derived_table: {sql:select xVar as x ;;}

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }

#   dimension: x {
#     type: number
#     sql: ${TABLE}.x ;;
#   }

#   dimension: xVar_exposed {
#     sql: xVar ;;
#   }
#   dimension: test_plus_1 {
#     sql:add_1(101)  ;;
#   }
#   dimension: test_intermediate_sql {
#     sql: intermediate_sql ;;
#   }
#   dimension: test_intermediate_result {
#     sql: intermediate_result ;;
#   }

#   set: detail {
#     fields: [
#       x
#     ]
#   }
# }
include: "/contribution_analysis_idea/iowa_liquor_stores_sales__main.lkml"
# view: test_data {
#   extends: [iowa_liquor_sales_sales]

# }

view: script_end {
  derived_table: {
    sql:
    select '1')
    --script end;;
  }
  dimension: test_script_end {sql:
    ';'
    ;;}
}
view: script_start {
  derived_table: {
    sql:--END OPEN COMMENT BLOCK FROM SQL_PREAMBLE to delay initial cte declaration*/
--Declare session variables, etc
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
CREATE OR REPLACE TABLE `thekitchentable.kevmccarthy_sandbox_dataset.procedural_queries_results_test` AS
(
    WITH {{_view._name}} as (
    select xVar, stringVar --create a dummy base table we can join real data to unconditionally.  might as well expose parameter/variable values
  ;;}
  # dimension: pl {sql:'placeholder';;}
  parameter: test_entry {
    type: string
    default_value: "unset"
  }
  dimension: stringVar {}
}




    # --;;#commented out end of sql
    # }#;; ;;


view: test_procedural_bq_syntax_v2 {
  # derived_table: {
  #   sql:
  #   select 'data' as regular_data, stringVar as passed_variable
  #   ;;
  # }
  dimension: regular_data {}

  parameter: test_entry {
    type: string
    default_value: "unset"
  }
  dimension: passed_variable {}
}
##8/25/25
explore: test_procedural_bq_syntax_v2 {
  sql_preamble:
    DECLARE stringVar STRING;
    SET stringVar = 't'; -- or parameter choices

create temp table test_procedural_bq_syntax_v2 AS (
select 'data' as regular_data, stringVar as passed_variable
union all
select 'data' as regular_data, stringVar as passed_variable
union all
select 'data2' as regular_data, stringVar as passed_variable
);

    create temp table result_set1 as

  ;;#;; special comment resets text colors in IDE ;;
  # /*

  sql_always_having:
  1=1
  )

) ww
) bb WHERE z__pivot_col_rank <= 16384
) aa
) xx
) zz
 WHERE (z__pivot_col_rank <= 12 OR z__is_highest_ranked_cell = 1) AND (z___pivot_row_rank <= 500 OR z__pivot_col_ordering = 1) ORDER BY z___pivot_row_rank
  ;

-- SELECT * FROM  thekitchentable.kevmccarthy_sandbox_dataset.result_set1
Select * FROM
(select * from
(select * from
(select * from
(select * from
(select * from
(select * from result_set1



  ;;

}


### This showed that dashboard url doesn't give filter values or other info
view:dashurl_liquid {
  derived_table: {
    sql: select '1' as id ;;
  }
  dimension: dashurl_liquid {
    sql: 'test_procedural_bq_syntax_v2.regular_data._is_selected:{{_explore._dashboard_url}}'
    --{{_explore._dashboard_url}}
    ;;
  }
}
explore: dashurl_liquid {
hidden: yes
}
