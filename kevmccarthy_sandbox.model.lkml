connection: "sample_bigquery_connection"

include: "/**/order_items.view"

explore: order_items_basic {
  from: order_items
}

include: "//thelook_ecommerce_basic_updates/thelook_ecommerce_basic_updates/events.view.lkml"
explore: events {}
