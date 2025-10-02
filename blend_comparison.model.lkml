connection: "sample_bigquery_connection"

# include: "//thelook_ecommerce_autogen_files/auto_gen_views/orders.view"
include: "//thelook_ecommerce_autogen_files/auto_gen_views/order_items.view" include: "//thelook_ecommerce_autogen_files/auto_gen_views/events.view"
include: "//thelook_ecommerce_autogen_files/auto_gen_views/products.view"

view: users {sql_table_name:`bigquery-public-data.thelook_ecommerce.users`;;measure: count {type: count}dimension: id {type: number}dimension: first_name {}dimension: last_name {}dimension: email {}dimension: age {type: number}dimension: gender {}dimension: state {}dimension: street_address {}dimension: postal_code {}dimension: city {}dimension: country {}dimension: latitude {type: number}dimension: longitude {type: number}dimension: traffic_source {}dimension_group: created_at {type: time}}view: empty_base {sql_table_name:(select null);;}
view: orders {    sql_table_name:`bigquery-public-data.thelook_ecommerce.orders`;;      measure: count {type:count}    dimension: order_id {    type: number  }    dimension: user_id {    type: number  }    dimension: status {  }    dimension: gender {  }    dimension_group: created_at {    type: time  }    dimension_group: returned_at {    type: time  }    dimension_group: shipped_at {    type: time  }    dimension_group: delivered_at {    type: time  }    dimension: num_of_item {    type: number}}

view: +users {dimension:primary_key {primary_key:yes sql:${id};;} measure:count {filters: [primary_key: "-NULL"]}}
view: +orders {dimension:primary_key {primary_key:yes sql:${order_id};;} measure:count {filters: [primary_key: "-NULL"]}}
view: +order_items {dimension:primary_key {primary_key:yes sql:${id};;} measure:count {filters: [primary_key: "-NULL"]}}
view: +events {dimension:primary_key {primary_key:yes sql:${id};;} measure:count {filters: [primary_key: "-NULL"]}}

view: +order_items {measure: total_sale_price {type:sum sql:${sale_price};;}}

#NEWLINE#improvements for this specific explore, e.g. remove duplicate fields#NEWLINE# view: order_items_view__order_items_explore {#NEWLINE#   extends: [order_items]#NEWLINE#   #hide foreign keys from field picker#NEWLINE#   dimension: inventory_item_id {group_label:"ID Fields"}#NEWLINE#   dimension: order_id {group_label:"ID Fields"}#NEWLINE#   dimension: product_id {group_label:"ID Fields"}#NEWLINE#   dimension: user_id {group_label:"ID Fields"}#NEWLINE#   #hide fields that are on other views and fit better in those other views#NEWLINE#   dimension_group: created_at {hidden:yes} #present in orders view#NEWLINE#   dimension_group: delivered_at {hidden:yes} #present in orders view#NEWLINE#   dimension_group: returned_at {hidden:yes} #present in orders view#NEWLINE#   dimension_group: shipped_at {hidden:yes} #present in orders view#NEWLINE#   dimension: status {hidden:yes} #present in orders view#NEWLINE# }#NEWLINE# view: orders_view__order_items_explore {#NEWLINE#   extends: [orders]#NEWLINE#   dimension: order_id {hidden:yes} #hide this and instead use the standard 'ID' field#NEWLINE# }#NEWLINE# view: products_view__order_items_explore {#NEWLINE#   extends: [products]#NEWLINE#   view_label: "Order Items"#NEWLINE# }
explore: blend_example_base {
  from: empty_base

  # first view has unusual join criteria (full join on false).
  # Question?: What is first view? Answer / Rule of Thumb: A view without foreign keys to views that have measures
  join: users {
    sql:full join ${users.SQL_TABLE_NAME} users on false;;relationship: one_to_many #relationship: many_to_one # we manage it ourselves
  }

  #Start with next view having reference to parent's primary key.  Use your normal join criteria.
#FULL JOIN REQUIRED TBD...
  join: orders {
    sql: left join ${orders.SQL_TABLE_NAME} orders on ${orders.user_id}=${users.id} ;;relationship: one_to_many #relationship: many_to_one # we manage it ourselves
  }
  #Continue recursively joining in another table with foreign key to prior join
  join: order_items {
    sql: left join ${order_items.SQL_TABLE_NAME} order_items on ${orders.order_id}=${order_items.order_id} ;;relationship: one_to_many #relationship: many_to_one # we manage it ourselves
  }

  #Note: Separate chain/tree of joins from above... events cannot be directly associated to orders or order_items, goes back to joining from original parent
  join: events {
    sql: left join ${events.SQL_TABLE_NAME} events on ${users.id}=${events.user_id};;relationship: one_to_many #relationship: many_to_one # we manage it ourselves
  }
  join: products {sql_on:${order_items.product_id}=${products.id};;relationship:many_to_one}
}

# view: +users {dimension: view_name {sql:${TABLE};;}}#EXAMPLE illustrates we need to add these to the view object, not the explore join name. view: +users {dimension: view_name {sql:${TABLE};;}}
# view: +orders {dimension: view_name {sql:${TABLE};;}}
# # view: +order_items {dimension: view_name {sql:${TABLE};;}}
# # view: +events {dimension: view_name {sql:${TABLE};;}}
# view: blend_support_view {parameter:is_extract__set_to_true_when_using_explore_source {type:yesno}}

# explore: +blend_example_base {
#   cancel_grouping_fields: [users.view_name,orders.view_name
#     # ,order_items.view_name,events.view_name
#   ]
#   join: blend_support_view {sql: ;;relationship:one_to_one}
# }

# #This view just gets the parent.  do not select other views in the explore_source
# view: blend_example_users {
#   extends: [users]
#   derived_table: {
#     explore_source: blend_example_base {
#       column: users {field:users.view_name}
#       # column: orders {field:orders.view_name}
#       # column: order_items {field:order_items.view_name}
#       # column: events {field:events.view_name}
#       bind_all_filters: yes
#       filters: [blend_support_view.is_extract__set_to_true_when_using_explore_source: "Yes"]
#     }
#   }
#   # measure:count {filters:}
#   dimension: primary_key {sql:1;;}#this is a placeholder that we need to reference to force joins
# }
# view: blend_example_orders {
#   extends: [orders]
#   derived_table: {
#     explore_source: blend_example_base {
#       #include views in the chain as appropriate.  see notes in example explore above to better understand this example... orders should have users but not events or order items (yet)
#       column: users {field:users.view_name}
#       column: orders {field:orders.view_name}
#       # column: order_items {field:order_items.view_name}
#       # column: events {field:events.view_name}
#       bind_all_filters: yes
#       filters: [blend_support_view.is_extract__set_to_true_when_using_explore_source: "Yes"]
#     }
#   }
#   dimension: primary_key {sql:1;;}
# }

# explore: +blend_example_base {
#   join: blend_example_users {
#     sql:  ;;# sql:full join (select blend_example_users.users.* from blend_example_users) users on true;;# sql:${blend_example_users.SQL_TABLE_NAME} ;;
#   relationship:one_to_one #relationship: many_to_one # we manage it ourselves
# }
# join: blend_example_orders {
#   sql:  ;;# sql:full join (select blend_example_users.users.* from blend_example_users) users on true;;# sql:${blend_example_users.SQL_TABLE_NAME} ;;
# relationship:one_to_one #relationship: many_to_one # we manage it ourselves
# }
# join: users {
#   sql:
#     {% if blend_support_view.is_extract__set_to_true_when_using_explore_source._parameter_value == 'true' %}
#       ${EXTENDED}
#     {% else %}
#     --false: parameter value output: {{blend_support_view.is_extract__set_to_true_when_using_explore_source._parameter_value}}
#     full join (select users.* from blend_example_users) as users on false
#     {% endif %}
#     ;;
# }
# join: orders {
#   sql:
#     {% if blend_support_view.is_extract__set_to_true_when_using_explore_source._parameter_value == 'true' %}
#       ${EXTENDED}
#     {% else %}
#     --false: parameter value output: {{blend_support_view.is_extract__set_to_true_when_using_explore_source._parameter_value}}
#     full join (select orders.* from blend_example_orders) as orders on false
#     {% endif %}
#     ;;
# }
# }



# view: read_sql_test {
#   derived_table: {sql:select * from ${blend_example_users.SQL_TABLE_NAME};;}
#   dimension: test {}
# }
# explore: +blend_example_base {
#   join: read_sql_test {sql: ;; relationship:one_to_one}
# }

# # include: "//thelook_ecommerce_autogen_files/auto_gen_views/products.view"
# # join: products {
# #   from: products_view__order_items_explore
# #   sql_on: ${order_items.product_id}=${products.id} ;;
# #   relationship: many_to_one
# # }

# # explore: read_sql_test {}
