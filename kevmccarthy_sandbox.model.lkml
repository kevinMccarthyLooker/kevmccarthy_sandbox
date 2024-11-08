connection: "sample_bigquery_connection"

include: "/**/order_items.view"

explore: order_items_basic {
  from: order_items
}
