#Connections and Includes
connection: "sample_bigquery_connection" include: "//thelook_ecommerce_autogen_files/auto_gen_views/products.view"
# # Setup common views:users,orders,order_items,events.
view: users {sql_table_name:`bigquery-public-data.thelook_ecommerce.users`;;measure: count {type: count}dimension: id {type: number}dimension: first_name {}dimension: last_name {}dimension: email {}dimension: age {type: number}dimension: gender {}dimension: state {}dimension: street_address {}dimension: postal_code {}dimension: city {}dimension: country {}dimension: latitude {type: number}dimension: longitude {type: number}dimension: traffic_source {}dimension_group: created_at {type: time}} view: orders {    sql_table_name:`bigquery-public-data.thelook_ecommerce.orders`;;      measure: count {type:count}    dimension: order_id {    type: number  }    dimension: user_id {    type: number  }    dimension: status {  }    dimension: gender {  }    dimension_group: created_at {    type: time  }    dimension_group: returned_at {    type: time  }    dimension_group: shipped_at {    type: time  }    dimension_group: delivered_at {    type: time  }    dimension: num_of_item {    type: number}} view: order_items {sql_table_name: `bigquery-public-data.thelook_ecommerce.order_items`;;measure: count {type: count}dimension: id {type: number}dimension: order_id {type: number}dimension: user_id {type: number}dimension: product_id {type: number}dimension: inventory_item_id {type: number}dimension: status {}dimension_group: created_at {type: time}dimension_group: shipped_at {type: time}dimension_group: delivered_at {type: time}dimension_group: returned_at {type: time}dimension: sale_price {type: number}} view: events {sql_table_name: `bigquery-public-data.thelook_ecommerce.events`;;measure: count {type: count}dimension: id {type: number}dimension: user_id {type: number}dimension: sequence_number {type: number}dimension: session_id {}dimension_group: created_at {type: time}dimension: ip_address {}dimension: city {}dimension: state {}dimension: postal_code {}dimension: browser {}dimension: traffic_source {}dimension: uri {}dimension: event_type {}}
# # Update Count field and add other basic measures
view: +users {dimension:primary_key {primary_key:yes sql:${id};;} measure:count {filters: [primary_key: "-NULL"]}} view: +orders {dimension:primary_key {primary_key:yes sql:${order_id};;} measure:count {filters: [primary_key: "-NULL"]}} view: +order_items {dimension:primary_key {primary_key:yes sql:${id};;} measure:count {filters: [primary_key: "-NULL"]}} view: +events {dimension:primary_key {primary_key:yes sql:${id};;} measure:count {filters: [primary_key: "-NULL"]}} view: +order_items {measure: total_sale_price {type:sum sql:${sale_price};;}}
# view: +users {dimension:special_table_name{sql:users;;}}
# view: v2 {extends: [users] derived_table:{sql:select * from {% if 1==0  /*${users_pushdown.SQL_TABLE_NAME}*/%};;}}
view: empty_base {sql_table_name:(select null from (select null) where 1=0);;}

view: +users {dimension: cancel_grouping_field {sql:1;;}}
# Continuing blend with filter pushdown... realized should we always be pushing down this way?
# Concept:should usually be pushing fiters down.
# explore: users {cancel_grouping_fields:[users.cancel_grouping_field]}

# explore: order_items {}
explore: order_items_and_users {
  join: users_pushdown {sql: ;; relationship:one_to_one}
  from: empty_base
  join: users {
    sql: full outer join
    {% if blend_support_view.is_extract__set_to_true_when_using_explore_source._parameter_value == 'true' %}
    `bigquery-public-data.thelook_ecommerce.users`
    {% else %}
      (select users.* from users_pushdown)

    {% endif %}
    as users on false ;;
    relationship: one_to_one # manage it ourselves
  }
}
# --${users.required_to_bring_in_pushdown_dimension}

explore: +order_items_and_users {
  join: blend_support_view {sql: ;; relationship:one_to_one}
  cancel_grouping_fields: [users.cancel_grouping_field]
  # cancel_grouping_fields: [users.cancel_grouping_field,blend_support_view.users__view_name]
}

view: blend_support_view {
  parameter:is_extract__set_to_true_when_using_explore_source {
    type:yesno
  }
  dimension: users__view_name {sql: users /*note: {{_field._name}} is here*/ ;;}
}


view: users_pushdown {
  extends: [users]
  derived_table: {
    explore_source: order_items_and_users {
      column: users {field:blend_support_view.users__view_name}
      column: users {field:users.cancel_grouping_field}
      bind_all_filters: yes
      filters: [blend_support_view.is_extract__set_to_true_when_using_explore_source: "Yes"]
    }
  }
  dimension: selection_helper_dimension {sql:'selection_helper_dimension';;}
  measure: selection_helper {sql:'selection_helper';;}
}

view: +users {
  dimension: required_to_bring_in_pushdown_dimension {
    # ${users_pushdown.selection_helper_dimension}
    sql:'';;
    html:{% assign x = users_pushdown.selection_helper_dimension._value %}{% if x < 0 %}{% endif %};;
  }
  measure: required_to_bring_in_pushdown {sql:${count} /*${users_pushdown.selection_helper}*/;;
    # html:{% assign x = users_pushdown.selection_helper %}
    # {% if x < 0 %}
    # {% else %}
    # {% endif %}
    # {{_rendered_value}}
    # ;;
  }
}
