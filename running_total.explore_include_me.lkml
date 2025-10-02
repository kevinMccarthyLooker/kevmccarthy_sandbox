include: "//thelook_ecommerce_autogen_files/basic_explores/order_items.explore.lkml"

view: +order_items {

}

view: running_total {
  derived_table: {
    sql:select *from unnest(generate_array(1,13,1)) as numbers;;
        # (${EXTENDED})
  }
  dimension: numbers {type:number}

}

explore: running_total {
  view_name: order_items
  join: running_total {type:cross relationship:one_to_one}
}
