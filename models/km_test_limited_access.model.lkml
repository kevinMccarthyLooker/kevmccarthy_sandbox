connection: "default_bigquery_connection"

view: order_items {sql_table_name: `bigquery-public-data.thelook_ecommerce.order_items`;;measure: count {type: count}dimension: id {type: number}dimension: order_id {type: number}dimension: user_id {type: number}dimension: product_id {type: number}dimension: inventory_item_id {type: number}dimension: status {}dimension_group: created_at {type: time}dimension_group: shipped_at {type: time}dimension_group: delivered_at {type: time}dimension_group: returned_at {type: time}dimension: sale_price {type: number}}
view: +order_items {dimension:primary_key {primary_key:yes sql:${id};;} measure:count {filters: [primary_key: "-NULL"]}}

view: +order_items {
  measure: count {
    drill_fields: [status,count]
  }
}
explore: order_items_for_limited_drill_test {
  view_name: order_items
}
