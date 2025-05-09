datagroup: example_datagroup_daily_build_at_midnight {sql_trigger:select date_trunc(current_timestamp(), DAY);;}

#Note: I did an initial build of the target table referenced below manually (test_incremental_pdt in the PDT dataset).  This works incrementally from there on an existing table
view: create_process_for_custom_incremental_PDT_test {
#   derived_table: {
#     datagroup_trigger: example_datagroup_daily_build_at_midnight
#     create_process: {
# # FOR INCREMENTAL LOAD: FIRST DELETE ANY DATA THAT ALREADY EXISTS FOR PERIOD WE PLAN TO INCREMENTALLY RELOAD
# #   HOW FAR BACK TO LOAD(AND THUS DELETE IN THIS STEP) MAY DEPEND ON HOW LATE DATA COULD ARRIVE, AND SHOULD COVER PERIOD SINCE PRIOR TRIGGER EVENT
# #.  MUST BE PARTITIONINIG ON THIS DATE FIELD ELSE THIS WILL SCAN WHOLE TABLE
#       sql_step:
#       DELETE FROM `test_incremental_pdt`
#       WHERE a_date > date_add(CURRENT_DATE(),INTERVAL -1 DAY);;

# # LOAD DATA FROM SOURCE INTO TARGET TABLE
#   # REPLACE WITH YOUR ACTUAL DERIVED TABLE LOGIC IN THE INNER QUERY
#   # SHOULD HAVE A WHER CLAUSE FILTERING ON SAME PERIOD OF TIME THAT WAS DELETED IN PRIOR STEP
#       sql_step:INSERT INTO `test_incremental_pdt`  (
#       SELECT a_date ,1 as value from (select  CURRENT_DATE() as a_date ) as dummy_table
#       where a_date >= date_add(current_date(),interval -1 DAY)
#       );;
# # LOOKER EXPECTS YOU TO DEFINE A WHOLE NEW TABLE AND LAND IT IN A DYNAMICALLY GENERATED LOCATION.
#   # SO THAT SUBSEQUENT LOOKER REFERENCES IN EXPLORE CAN USE THE DYNAMIC NAME WE"LL GENERATE... WE'LL LAND A VIEW THERE INSTEAD (WHICH ALWAYS POINTS TO OUR PERMANENT TABLE)
#       sql_step:CREATE OR REPLACE VIEW ${SQL_TABLE_NAME} as (select * from `kitchenTablePDTs.test_incremental_pdt`);;
#     }
#   }
  #dimensions corresponding to my Proof Of Concept
  dimension: a_date {type:date}
  dimension: value {}

}
explore: create_process_for_custom_incremental_PDT_test {}
