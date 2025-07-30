include: "//thelook_ecommerce_autogen_files/auto_gen_views/order_items.view.lkml"
view: agg_awareness_with_ratio_of_sums {
  extends: [order_items]
  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
  }
  measure: ratio_sales_over_count {
    type: number
    sql: ${total_sale_price}/${count} ;;
  }
}
explore: agg_awareness_with_ratio_of_sums {

}

explore: +agg_awareness_with_ratio_of_sums {

  aggregate_table: rollup__count__ratio_sales_over_count__total_sale_price2 {
    query: {
      dimensions: [agg_awareness_with_ratio_of_sums.status]
      measures: [ratio_sales_over_count]
    }
    materialization: {persist_for: "1 hour"}
  }
}


  # aggregate_table: rollup__count__ratio_sales_over_count__total_sale_price {
  #   query: {
  #     dimensions: [agg_awareness_with_ratio_of_sums.status]
  #     measures: [count, ratio_sales_over_count, total_sale_price]
  #   }
  #   materialization: {persist_for: "1 hour"}

  #   # Please specify a datagroup_trigger or sql_trigger_value
  #   # See https://cloud.google.com/looker/docs/r/lookml/types/aggregate_table/materialization
  # }
