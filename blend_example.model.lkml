connection: "sample_bigquery_connection"
include: "//thelook_ecommerce_autogen_files/auto_gen_views/products.view"

view: users {sql_table_name:`bigquery-public-data.thelook_ecommerce.users`;;measure: count {type: count}dimension: id {type: number}dimension: first_name {}dimension: last_name {}dimension: email {}dimension: age {type: number}dimension: gender {}dimension: state {}dimension: street_address {}dimension: postal_code {}dimension: city {}dimension: country {}dimension: latitude {type: number}dimension: longitude {type: number}dimension: traffic_source {}dimension_group: created_at {type: time}}
view: orders {    sql_table_name:`bigquery-public-data.thelook_ecommerce.orders`;;      measure: count {type:count}    dimension: order_id {    type: number  }    dimension: user_id {    type: number  }    dimension: status {  }    dimension: gender {  }    dimension_group: created_at {    type: time  }    dimension_group: returned_at {    type: time  }    dimension_group: shipped_at {    type: time  }    dimension_group: delivered_at {    type: time  }    dimension: num_of_item {    type: number}}
view: order_items {sql_table_name: `bigquery-public-data.thelook_ecommerce.order_items`;;measure: count {type: count}dimension: id {type: number}dimension: order_id {type: number}dimension: user_id {type: number}dimension: product_id {type: number}dimension: inventory_item_id {type: number}dimension: status {}dimension_group: created_at {type: time}dimension_group: shipped_at {type: time}dimension_group: delivered_at {type: time}dimension_group: returned_at {type: time}dimension: sale_price {type: number}}
view: events {sql_table_name: `bigquery-public-data.thelook_ecommerce.events`;;measure: count {type: count}dimension: id {type: number}dimension: user_id {type: number}dimension: sequence_number {type: number}dimension: session_id {}dimension_group: created_at {type: time}dimension: ip_address {}dimension: city {}dimension: state {}dimension: postal_code {}dimension: browser {}dimension: traffic_source {}dimension: uri {}dimension: event_type {}}


view: +users {dimension:primary_key {primary_key:yes sql:${id};;} measure:count {filters: [primary_key: "-NULL"]}}
view: +orders {dimension:primary_key {primary_key:yes sql:${order_id};;} measure:count {filters: [primary_key: "-NULL"]}}
view: +order_items {dimension:primary_key {primary_key:yes sql:${id};;} measure:count {filters: [primary_key: "-NULL"]}}
view: +events {dimension:primary_key {primary_key:yes sql:${id};;} measure:count {filters: [primary_key: "-NULL"]}}

view: +order_items {measure: total_sale_price {type:sum sql:${sale_price};;}}

#NEWLINE#improvements for this specific explore, e.g. remove duplicate fields#NEWLINE# view: order_items_view__order_items_explore {#NEWLINE#   extends: [order_items]#NEWLINE#   #hide foreign keys from field picker#NEWLINE#   dimension: inventory_item_id {group_label:"ID Fields"}#NEWLINE#   dimension: order_id {group_label:"ID Fields"}#NEWLINE#   dimension: product_id {group_label:"ID Fields"}#NEWLINE#   dimension: user_id {group_label:"ID Fields"}#NEWLINE#   #hide fields that are on other views and fit better in those other views#NEWLINE#   dimension_group: created_at {hidden:yes} #present in orders view#NEWLINE#   dimension_group: delivered_at {hidden:yes} #present in orders view#NEWLINE#   dimension_group: returned_at {hidden:yes} #present in orders view#NEWLINE#   dimension_group: shipped_at {hidden:yes} #present in orders view#NEWLINE#   dimension: status {hidden:yes} #present in orders view#NEWLINE# }#NEWLINE# view: orders_view__order_items_explore {#NEWLINE#   extends: [orders]#NEWLINE#   dimension: order_id {hidden:yes} #hide this and instead use the standard 'ID' field#NEWLINE# }#NEWLINE# view: products_view__order_items_explore {#NEWLINE#   extends: [products]#NEWLINE#   view_label: "Order Items"#NEWLINE# }
view: empty_base {sql_table_name:(select null);;}
view: +empty_base {
sql_table_name:
{% if blend_support_view.is_extract__set_to_true_when_using_explore_source._parameter_value == 'true' %}${EXTENDED}
{% else %}
--empty base start --full join (
(
select *,measures.users as users__measures,measures.orders as orders__measures, measures.order_items as order_items__measures, measures.events as events__measures from
(
/*
  users._in_query:{{users._in_query}}
  orders._in_query:{{orders._in_query}}
  ordedr_items._in_query:{{order_items._in_query}}
  events._in_query:{{events._in_query}}
{% if events._in_query %}  union all select as value (select as struct blend__events.*)               from blend__events        {% endif %}

*/

          select as value (select as struct blend__users.*        ,(select as struct blend__users.*                                                               ) measures)    from blend__users
union all select as value (select as struct blend__orders.*       ,(select as struct blend__orders.*      replace(case when 1=0 then users else null end as users)) measures)    from blend__orders
union all select as value (select as struct blend__order_items.*  ,(select as struct blend__order_items.* replace(case when 1=0 then users else null end as users ,case when 1=0 then orders else null end as orders)) measures)    from blend__order_items
union all select as value (select as struct blend__events.*       ,(select as struct blend__events.*      replace(case when 1=0 then users else null end as users)) measures)    from blend__events
)
)
--bypass empty view name{% endif %};; #
#;;#Resetting Colors in IDE
# union all

# select users.* from blend__users) as users on false

}

view: end_blended_from_clause {sql_table_name:;;}
explore: blend_example_base {
  # sql_preamble:
  # select * from ${blend__users.id}
  # ;;
  from: empty_base

  # first view has unusual join criteria (full join on false).
  # Question?: What is first view? Answer / Rule of Thumb: A view without foreign keys to views that have measures
  join: users {
    sql:left join ${users.SQL_TABLE_NAME} users on true;;relationship: one_to_one #relationship: many_to_one # we manage it ourselves
  }

  #Start with next view having reference to parent's primary key.  Use your normal join criteria.
#FULL JOIN REQUIRED TBD...
  join: orders {
    sql: left join ${orders.SQL_TABLE_NAME} orders on ${orders.user_id}=${users.id} ;;relationship: one_to_one #relationship: many_to_one # we manage it ourselves
  }
  #Continue recursively joining in another table with foreign key to prior join
  join: order_items {
    sql: left join ${order_items.SQL_TABLE_NAME} order_items on ${orders.order_id}=${order_items.order_id} ;;relationship: one_to_one #relationship: many_to_one # we manage it ourselves
  }

  #Note: Separate chain/tree of joins from above... events cannot be directly associated to orders or order_items, goes back to joining from original parent
  join: events {
    sql: left join ${events.SQL_TABLE_NAME} events on ${users.id}=${events.user_id};;relationship: one_to_one #relationship: many_to_one # we manage it ourselves
  }

  join: products {sql_on:${order_items.product_id}=${products.id};;relationship:many_to_one}
}

view: +users {dimension: view_name {sql:${TABLE};;}}#EXAMPLE illustrates we need to add these to the view object, not the explore join name. view: +users {dimension: view_name {sql:${TABLE};;}}
view: +orders {dimension: view_name {sql:${TABLE};;}}
view: +order_items {dimension: view_name {sql:${TABLE};;}}
view: +events {dimension: view_name {sql:${TABLE};;}}

view: +users        {parameter: skip_join {type:yesno}}
view: +orders       {parameter: skip_join {type:yesno}}
view: +order_items  {parameter: skip_join {type:yesno}}
view: +events       {parameter: skip_join {type:yesno}}

view: blend_support_view {parameter:is_extract__set_to_true_when_using_explore_source {type:yesno}}



explore: +blend_example_base {
  cancel_grouping_fields: [users.view_name]#only need one cancel grouping field (suggest using base/parent view .view_name, and to not mention and metrics.
  join: blend_support_view {sql: ;;relationship:one_to_one}
}

#This view just gets the parent.  do not select other views in the explore_source
# view: blend__users {
view: blend__users {
  extends: [users]
  derived_table: {
    explore_source: blend_example_base {
      column: users          {field:users.view_name       }
      #bypass other joins
      column: orders         {field:orders.view_name      }filters: [orders.skip_join:"Yes"]
      column: order_items    {field:order_items.view_name }filters: [order_items.skip_join:"Yes"]
      column: events         {field:events.view_name      }filters: [events.skip_join:"Yes"]
      bind_all_filters: yes
      filters: [blend_support_view.is_extract__set_to_true_when_using_explore_source: "Yes"]
    }
  }
  dimension: primary_key {sql:1;;}#this is a placeholder that we need to reference to force joins
}
# view: blend__users2 {dimension:sql:select * from blend__users;;}
view: blend__orders {
  extends: [orders]
  derived_table: {
    explore_source: blend_example_base {
      column: users          {field:users.view_name       }
      column: orders         {field:orders.view_name      }filters: [orders.skip_join:"No"]
      #bypass other joins
      column: order_items    {field:order_items.view_name }filters: [order_items.skip_join:"Yes"]
      column: events         {field:events.view_name      }filters: [events.skip_join:"Yes"]
      bind_all_filters: yes
      filters: [blend_support_view.is_extract__set_to_true_when_using_explore_source: "Yes"]
    }
  }
  dimension: primary_key {sql:1;;}#this is a placeholder that we need to reference to force joins
}
view: blend__order_items {
  extends: [order_items]
  derived_table: {
    explore_source: blend_example_base {
      column: users          {field:users.view_name       }
      column: orders         {field:orders.view_name      }filters: [orders.skip_join:"No"]
      column: order_items    {field:order_items.view_name }filters: [order_items.skip_join:"No"]
      #bypass other joins
      column: events         {field:events.view_name      }filters: [events.skip_join:"Yes"]
      bind_all_filters: yes
      filters: [blend_support_view.is_extract__set_to_true_when_using_explore_source: "Yes"]
    }
  }
  dimension: primary_key {sql:1;;}#this is a placeholder that we need to reference to force joins
}
view: blend__events {
  extends: [order_items]
  derived_table: {
    explore_source: blend_example_base {
      column: users          {field:users.view_name       }
      column: orders         {field:orders.view_name      }filters: [orders.skip_join:"Yes"]
      column: order_items    {field:order_items.view_name }filters: [order_items.skip_join:"Yes"]
      #bypass other joins
      column: events         {field:events.view_name      }filters: [events.skip_join:"No"]
      bind_all_filters: yes
      filters: [blend_support_view.is_extract__set_to_true_when_using_explore_source: "Yes"]
    }
  }
  dimension: primary_key {sql:1;;}#this is a placeholder that we need to reference to force joins
}



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
# #BETTER WAY?
#   dimension: primary_key {sql:1;;}
# }
# view: blend_example_order_items {
#   extends: [orders]
#   derived_table: {
#     explore_source: blend_example_base {
#       #include views in the chain as appropriate.  see notes in example explore above to better understand this example... orders should have users but not events or order items (yet)
#       column: users {field:users.view_name}
#       column: orders {field:orders.view_name}
#       column: order_items {field:order_items.view_name}
#       # column: events {field:events.view_name}
#       bind_all_filters: yes
#       filters: [blend_support_view.is_extract__set_to_true_when_using_explore_source: "Yes"]
#     }
#   }
# #BETTER WAY?
#   dimension: primary_key {sql:1;;}
# }

view: users__measures       {extends:[users]}
view: orders__measures      {extends:[orders]}
view: order_items__measures {extends:[order_items]}
view: events__measures      {extends:[events]}


explore: +blend_example_base {
  join: blend__users {sql:  ;;relationship:one_to_one }#relationship: many_to_one # we manage it ourselves

  join: blend__orders       {sql:  ;;relationship:one_to_one }#relationship: many_to_one # we manage it ourselves
  join: blend__order_items  {sql:  ;;relationship:one_to_one }#relationship: many_to_one # we manage it ourselves
  join: blend__events       {sql:  ;;relationship:one_to_one }#relationship: many_to_one # we manage it ourselves

  join: users__measures       {sql:  ;;relationship:one_to_one }#relationship: many_to_one # we manage it ourselves
  join: orders__measures      {sql:  ;;relationship:one_to_one }#relationship: many_to_one # we manage it ourselves
  join: order_items__measures {sql:  ;;relationship:one_to_one }#relationship: many_to_one # we manage it ourselves
  join: events__measures      {sql:  ;;relationship:one_to_one }#relationship: many_to_one # we manage it ourselves




join: users {
  sql:{% if blend_support_view.is_extract__set_to_true_when_using_explore_source._parameter_value == 'true' %}
        ${EXTENDED} and not {% parameter blend__users.skip_join %}
    {% endif %}
    ;;
}
join: orders {
  sql:
    {% if blend_support_view.is_extract__set_to_true_when_using_explore_source._parameter_value == 'true' %}
      ${EXTENDED} and not {% parameter orders.skip_join %}
    {% else %}
--WIP: NOTES ONLY.    --full join (select orders.* from blend_example_orders) as orders on false
    {% endif %}
    ;;
}
  join: order_items {
    sql:
    {% if blend_support_view.is_extract__set_to_true_when_using_explore_source._parameter_value == 'true' %}
    ${EXTENDED} and not {% parameter order_items.skip_join %}
    {% else %}
    --WIP: NOTES ONLY.    --full join (select orders.* from blend_example_orders) as orders on false
    {% endif %}
    ;;
  }
  join: events {
    sql:
    {% if blend_support_view.is_extract__set_to_true_when_using_explore_source._parameter_value == 'true' %}
    ${EXTENDED} and not {% parameter events.skip_join %}
    {% else %}
    --WIP: NOTES ONLY.    --full join (select orders.* from blend_example_orders) as orders on false
    {% endif %}
    ;;
  }
# always_filter: {filters:[users.btest: "1"]}
}



# view: read_sql_test {
#   # derived_table: {sql:select * from ${blend_example_users.SQL_TABLE_NAME};;}${blend_example_all.SQL_TABLE_NAME}
#   derived_table: {sql:select * from ;;}
#   dimension: test {}
# }
# explore: +blend_example_base {
#   join: read_sql_test {sql: ;; relationship:one_to_one}
# }

# include: "//thelook_ecommerce_autogen_files/auto_gen_views/products.view"
# join: products {
#   from: products_view__order_items_explore
#   sql_on: ${order_items.product_id}=${products.id} ;;
#   relationship: many_to_one
# }

# explore: read_sql_test {}

view: +users {
  #wip
  measure: required_magic_field_brings_in_subqueries {
    type: sum
    sql: 1 ;;
    html:
    {{blend__users.count._rendered_value}}
    {{blend__orders.count._rendered_value}}
    {{blend__order_items.count._rendered_value}}
    {{blend__events.count._rendered_value}}
    ;;
  }

}





###
# 10/2/2025
#See dashboard to compare.
#Examples show dramatic improvement in cases that would otherwise be a fannout
#I suspect ecomm data not big enough to reallly show the issue
#much more optimization can be done with physicalization, and more liquid checks
#need to figure out better way to force the subqueries
#need to make more helper object to make it cleaner and more intuitive..
#need to test apply it to another explore
#show fabio and bryan weber
