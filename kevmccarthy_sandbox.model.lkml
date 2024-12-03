
include: "//thelook_ecommerce_autogen_files/basic_model_params"

include: "//thelook_ecommerce_autogen_files/basic_explores/events.explore.lkml"
# explore: +events {}

include: "//thelook_ecommerce_autogen_files/basic_explores/order_items.explore.lkml"
# explore: +order_items {}


view: a_pdt {
  derived_table: {
    sql: select 1 as id union all select 101 as id;;
    persist_for: "1 second"
  }
  dimension: id {type:number}
}
explore: a_pdt {}


include: "/**/bq_information_schema_columns.view"
explore: bq_information_schema_columns {}
