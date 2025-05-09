include: "//thelook_ecommerce_autogen_files/auto_gen_views/order_items.view.lkml"
view: ismail_tigrek_formatting_20250429_order_items {
  view_label: "test"
  fields_hidden_by_default: no
  extends: [order_items]
  measure: total_sales {
    type: sum
    sql: ${sale_price} ;;
  }
  measure: total_complete_sales {
    type: sum
    filters: [status: "Complete"]
    sql: ${sale_price} ;;
  }
  measure: complete_sales_percent {
    type: string
    sql: concat(round(${total_complete_sales}/nullif(${total_sales},0),3)*100,'%') ;;
    # value_format_name:

  }

}
# explore: ismail_tigrek_formatting_20250429_order_items {}
