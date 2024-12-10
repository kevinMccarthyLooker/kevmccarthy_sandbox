view: stable_table_name_pdt {
  derived_table: {
    sql: select 4 as id union all select 101 as id;;
  }
  dimension: id {type:number}
}
