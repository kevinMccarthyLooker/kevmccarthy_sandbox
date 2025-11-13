
view: order_items_b {
  derived_table: {
    sql:
          SELECT 'Current' as label, oi.created_at,* from (select oi, if(false,oi,null) as yday,if(false,oi,null) as lw FROM `bigquery-public-data.thelook_ecommerce.order_items` as oi)
union all SELECT 'Yday' as label, yday.created_at,* from (select if(false,oi,null), (select as struct oi.* replace(date_add(oi.created_at,interval 1 day) as created_at)) as yday,if(false,oi,null) as lw FROM `bigquery-public-data.thelook_ecommerce.order_items` as oi)
union all SELECT 'Last Week' as label, lw.created_at,* from (select if(false,oi,null), if(false,oi,null) as yday, (select as struct oi.* replace(date_trunc(date_add(oi.created_at,interval 7 day),week) as created_at)) as lw FROM `bigquery-public-data.thelook_ecommerce.order_items` as oi)

    ;;
  }

  dimension: special_table {
    sql:{{_view._name}};;
  }

  measure: count {
    type: count
  }

  dimension: id {
    type: number
    sql: ${special_table}.id ;;
  }

  dimension: order_id {
    type: number
    sql: ${special_table}.order_id ;;
  }

  dimension: user_id {
    type: number
    sql: ${special_table}.user_id ;;
  }

  dimension: product_id {
    type: number
    sql: ${special_table}.product_id ;;
  }

  dimension: inventory_item_id {
    type: number
    sql: ${special_table}.inventory_item_id ;;
  }

  dimension: status {
    type: string
    sql: ${special_table}.status ;;
  }

  dimension_group: created_at {
    type: time
    sql: ${special_table}.created_at ;;
  }

  dimension_group: shipped_at {
    type: time
    sql: ${special_table}.shipped_at ;;
  }

  dimension_group: delivered_at {
    type: time
    sql: ${special_table}.delivered_at ;;
  }

  dimension_group: returned_at {
    type: time
    sql: ${special_table}.returned_at ;;
  }

  dimension: sale_price {
    type: number
    sql: ${special_table}.sale_price ;;
  }

  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
  }

}

view: order_items_b_current {
  extends: [order_items_b]
  dimension: special_table {sql:order_items_b.oi;;}
}
view: order_items_b_yday {
  extends: [order_items_b]
  dimension: special_table {sql:order_items_b.yday;;}
}
view: order_items_lw {
  extends: [order_items_b]
  dimension: special_table {sql:order_items_b.lw;;}
}
explore: order_items_b {
  join: order_items_b_current {sql:;; relationship:one_to_one}
  join: order_items_b_yday {sql:;; relationship:one_to_one}
  join: order_items_lw {sql:;; relationship:one_to_one}
}
