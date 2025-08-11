connection: "kevmccarthy_bq"

view: order_items {
  derived_table: {sql: SELECT * FROM `bigquery-public-data.thelook_ecommerce.order_items` ;;} # original source view could be a typical single physical table source with sql_table_name, but also can be a derived table like.  #Also note that referencing * or many fields in a CTE doesn't necessarily impact performance.  BQ Query engine smart enough to scan only columns it needs to provide the final outputs.
  dimension_group:  created_at        {type: time}
  dimension_group:  shipped_at        {type: time}
  dimension_group:  delivered_at      {type: time}
  dimension_group:  returned_at       {type: time}
  dimension:        order_id          {type: number}
  dimension:        user_id           {type: number}
  dimension:        product_id        {type: number}
  dimension:        inventory_item_id {type: number}
  dimension:        status            {}
  dimension:        sale_price        {type: number}
  dimension:        id                {type: number primary_key:yes}
  measure:          count             {type: count}
}

explore: studio_connector_basic_order_items {
  from: order_items
  view_name: order_items
}
view: returned_items_by_returned_date {
  derived_table: {
    explore_source: studio_connector_basic_order_items {
      column: returned_date {field:order_items.returned_at_date}
      column: returned_count {field:order_items.count}
      bind_filters: {from_field:combined_explore_parameters.date_filter to_field:order_items.returned_at_date}
    }
  }
  dimension: returned_date {}
  dimension: returned_count {type:number hidden:yes}
  measure: total_returned_count {type:sum sql:${returned_count};;}
}
view: shipped_items_by_shipped_date {
  derived_table: {
    explore_source: studio_connector_basic_order_items {
      column: shipped_date {field:order_items.shipped_at_date}
      column: shipped_count {field:order_items.count}
      bind_filters: {from_field:combined_explore_parameters.date_filter to_field:order_items.shipped_at_date}
    }
  }
  dimension: shipped_date {}
  dimension: shipped_count {type:number hidden:yes}
  measure: total_shipped_count {type:sum sql:${shipped_count};;}
}
view: combined_explore_parameters {
  filter: date_filter {type:date}
}
explore: shipped_and_returned_items {
  from: shipped_items_by_shipped_date
  join: returned_items_by_returned_date {
    type: full_outer
    relationship: one_to_one
    sql_on: ${shipped_and_returned_items.shipped_date}=${returned_items_by_returned_date.returned_date} ;;
  }
  join: combined_explore_parameters {
    sql:  ;;
    relationship: one_to_one
  }
}
