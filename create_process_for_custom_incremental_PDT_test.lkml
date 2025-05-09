datagroup: test {sql_trigger:select current_timestamp();;}

view: create_process_for_custom_incremental_PDT_test {
  derived_table: {
    #this was used to create it for the first time
    # create_process: {
    #   # sql_step:
    #   #   delete TABLE ${SQL_TABLE_NAME} IF EXISTS
    #   # ;;
    #   sql_step:
    #   CREATE TABLE ${SQL_TABLE_NAME} as (SELECT '1' as id)
    #   ;;
    # }
    publish_as_db_view: yes
    # create_process: {
    #   sql_step:
    #     delete FROM ${SQL_TABLE_NAME} WHERE id = '1'
    #   ;;
    #   sql_step:
    #   INSERT INTO TABLE ${SQL_TABLE_NAME} as (SELECT '2' as id)
    #   ;;
    # }
    sql: SELECT '1' as id ;;
    # persist_for: "1 second"
    datagroup_trigger: test
  }
  dimension: id {}
}
explore: create_process_for_custom_incremental_PDT_test {}
