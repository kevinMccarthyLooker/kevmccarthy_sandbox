
view: session_lookup {
  derived_table: {
    sql: SELECT
          events.session_id  AS events_session_id,
          COUNT(*) AS events_count,
          COUNT(CASE WHEN (( events.event_type  ) = 'purchase') THEN 1 ELSE NULL END) AS purchase_events_count,
          min(events.created_at) as first_event,
          max(events.created_at) as last_event
        FROM `bigquery-public-data.thelook_ecommerce.events` events
        GROUP BY all ;;
  }
  dimension: events_session_id {}
  dimension: events_count {type: number}
  dimension: purchase_events_count {type: number}
  dimension_group: first_event {type: time}
  dimension_group: last_event {type: time}
}

view: user_lookup {
  derived_table: {
    sql: SELECT user_id,
          sum(lifetime_events) as lifetime_events,
          sum(lifetime_orders) as lifetime_orders
         FROM (          select user_id, lifetime_events,null as lifetime_orders from (SELECT user_id,COUNT(*) as lifetime_events FROM `bigquery-public-data.thelook_ecommerce.events` group by all) user_events
               union all select user_id, null as lifetime_events,lifetime_orders from (SELECT user_id,COUNT(*) as lifetime_orders  FROM `bigquery-public-data.thelook_ecommerce.order_items` group by all ) user_orders
              )
         group by all;;
  }
  dimension: user_id {type: number}
  dimension: lifetime_events {type: number}
  dimension: lifetime_orders {type: number}
}

view: user_order_facts {
  derived_table: {
    sql: SELECT
          (DATE(orders.created_at )) AS created_at_date,
          order_items.user_id  AS user_id,
          order_items.product_id  AS product_id,
          COALESCE(SUM(order_items.sale_price ), 0) AS total_sale_price,
          COALESCE(SUM(CASE WHEN (( order_items.status  ) = 'Complete') THEN order_items.sale_price  ELSE NULL END), 0) AS total_sales_completed
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS order_items
LEFT JOIN `bigquery-public-data.thelook_ecommerce.orders` AS orders ON order_items.order_id=orders.order_id
GROUP BY ALL;;
  }
  dimension_group: created_at_date {type: time timeframes: [date,month,year] datatype: date}
  dimension: user_id {}
  dimension: product_id {}
  dimension: primary_key {primary_key:yes sql:concat(${created_at_date_date},${user_id},${product_id});;}
  dimension: total_sale_price__dimension {sql:${TABLE}.total_sale_price;;type:number}
  measure:total_sale_price {type:sum sql:${total_sale_price__dimension};;}
  dimension: total_sales_completed__dimension {sql:${TABLE}.total_sales_completed;;type:number}
  measure:total_sales_completed {type:sum sql:${total_sales_completed__dimension};;}
}

view: user_session_facts {
  derived_table: {
    sql: SELECT
          (DATE(events.created_at )) AS created_at_date,
          events.user_id  AS user_id,
          events.session_id  AS session_id,
          COUNT(*) AS events_count
        FROM `bigquery-public-data.thelook_ecommerce.events` events
        GROUP BY all;;
  }
  dimension_group: created_at_date {type: time timeframes: [date,month,year] datatype: date}
  dimension: user_id {}
  dimension: session_id {}
  dimension: primary_key {primary_key:yes sql:concat(${created_at_date_date},${user_id},${session_id});;}
  dimension: events_count_dimension {sql:${TABLE}.events_count;; type:number}
  measure: total_events_count {type:sum sql:${events_count_dimension};;}
}

view: empty_base_for_facts_blend_example {
  derived_table: {sql:select null;;}
  dimension: dynamic_join_criteria {
sql:
  {% assign join_criteria_sql = '' %}
  {% assign count_of_facts = 0 %}
  {% if user_order_facts._in_query %}{% assign count_of_facts = count_of_facts | plus: 1 %}{%endif%}
  {% if user_session_facts._in_query %}{% assign count_of_facts = count_of_facts | plus: 1 %}{%endif%}
  {% if count_of_facts <= 1 %}
    true -- resolve to full outer join from empty_base to the only one actual table on true
  {% elsif count_of_facts > 1 %}
    --multiple facts are involved.  Want to align rows with join criteria matching corresponding joinable fields from all facts, and use with full outer join
    --introduce keys from the first possibly joined fact table
    {% assign this_field_join_criteria_sql = '' %}
    {% if user_order_facts._in_query %}{% assign this_field_join_criteria_sql = this_field_join_criteria_sql | append: ' = user_order_facts.user_id' %}{% endif %}
    {% if user_session_facts._in_query %}{% assign this_field_join_criteria_sql = this_field_join_criteria_sql | append: ' = user_session_facts.user_id' %}{% endif %}
    --more joins' fields would be added here
    {% assign this_field_join_criteria_sql = this_field_join_criteria_sql | remove_first: ' = '%}
    {% assign join_criteria_sql = join_criteria_sql | append: this_field_join_criteria_sql %}

    --introduce keys from the second possibly joined fact table
    {% assign join_criteria_sql = join_criteria_sql | append: ' and '%}

    {% assign this_field_join_criteria_sql = '' %}
    {% if user_order_facts._in_query %}{% assign this_field_join_criteria_sql = this_field_join_criteria_sql | append: ' = user_order_facts.created_at_date' %}{% endif %}
    {% if user_session_facts._in_query %}{% assign this_field_join_criteria_sql = this_field_join_criteria_sql | append: ' = user_session_facts.created_at_date' %}{% endif %}
    --more joins' fields would be added here
    {% assign this_field_join_criteria_sql = this_field_join_criteria_sql | remove_first: ' = '%}
    {% assign join_criteria_sql = join_criteria_sql | append: this_field_join_criteria_sql %}

    --more conformed dimension keys would be similarly added here
    --handling likely needs adjusting for 3+ fact tables... this implies we'd end up with f1.a=f2.a=f3.a... logic yet to be completed described below
    -- -- Will need to get from f1.a=f2.a=f3.a to f1.a=f2.a and f2.a=f3.a...
    -- -- Approach in mind:
    -- -- -- 1) make a string array by splitting on '=',
    -- -- -- 2) for all view names except first and last...
    -- -- -- -- replace:=view_name_var.field_name  with  =view_name_var.field_name and view_name_var.field_name
{% endif %}
{{join_criteria_sql}}
;;
  }
}
# view: blending_view {
#   derived_table: {
#     sql:
#     select
#     *,
#     coalesce(user_order_facts.user_id,user_session_facts.user_id) as coalesced_user_id,
#     --coalesce({{user_order_facts.session_id._sql}},{{user_session_facts.session_id._sql}}) as coalesced_session_id
#     --test:{% if user_order_facts.session_id ='' %}null{% else %}{{user_order_facts.session_id._sql}}{%endif%}

#     from (select null) as empty_base_table
# full outer join ${user_order_facts.SQL_TABLE_NAME} as user_order_facts on FALSE
# full outer join ${user_session_facts.SQL_TABLE_NAME} as user_session_facts on FALSE
#     ;;
#   }
#   #results produced by select *:
#   dimension: f0_ {
#     type: number
#   }

#   # dimension_group: created_at_date {type: time timeframes: [date,month,year] datatype: date}
#   # dimension: user_id {}
#   # dimension: product_id {type: number}
#   # dimension: total_sale_price {type: number}
#   # dimension: total_sales_completed {type: number}
#   # dimension_group: created_at_date_1 {type: time timeframes: [date,month,year] datatype: date}
#   # dimension: user_id_1 {type: number}
#   # dimension: session_id {}
#   # dimension: events_count {type: number}

#   dimension: session_id {}
#   dimension: total_sale_price_dimension {sql:${TABLE}.total_sale_price;;}
#   measure: total_sale_price {type:sum sql:${total_sale_price_dimension};;}
#   dimension: total_sales_completed_dimension {sql:${TABLE}.total_sales_completed;;}
#   measure: total_sales_completed {type:sum sql:${total_sales_completed_dimension};;}
#   dimension:  events_count_dimension {sql:${TABLE}.total_sale_price;;}
#   measure: total_events_count {type:sum sql:${events_count_dimension};;}

#   dimension: coalesced_user_id {}

# }

# explore: blending_facts {
#   from: empty_base_for_facts_blend_example
#   always_join: [blending_view]
#   join: blending_view {sql: full outer join blending_view on false;; relationship: one_to_one}
#   join: user_lookup {sql_on: ${blending_view.coalesced_user_id}=${user_lookup.user_id} ;; relationship: one_to_one}
#   join: session_lookup {sql_on: ${blending_view.session_id}=${session_lookup.events_session_id} ;; relationship: one_to_one}

#   join: user_order_facts {sql: ;; relationship:one_to_one}
#   join: user_session_facts {sql: ;; relationship:one_to_one}
# }

view: in_query_tracker {dimension: in_query_tracker   {sql:;; hidden:yes }}
view: +in_query_tracker {dimension: in_query_tracker {sql:${EXTENDED}{%- if user_order_facts._in_query -%},user_order_facts{%- endif -%};;}}
view: +in_query_tracker {dimension: in_query_tracker {sql:${EXTENDED}{%- if user_session_facts._in_query -%},user_session_facts{%- endif -%};;}}
view: +in_query_tracker {

  dimension: join_criteria_template {
    hidden:yes
    sql:{{- in_query_tracker._sql | replace: ',','.REPLACE_ME_WITH_JOIN_FIELD_NAME,' -}};;
  }
}

view: +user_order_facts {
  dimension:earlier_in_query_views {
    sql: {%- assign this_view_name = 'user_order_facts' -%}
    {%- assign result_sql = in_query_tracker.join_criteria_template._sql | split: this_view_name | first -%}
    {{- result_sql -}}
    ;;
  }
}
view: +user_session_facts {
  dimension:earlier_in_query_views {
    sql:
    {%- assign this_view_name = 'user_session_facts' -%}
    {%- assign result_sql = in_query_tracker.join_criteria_template._sql | split: this_view_name | first -%}
    {{- result_sql -}}
    ;;
  }
}


explore: blending_facts {
  from: empty_base_for_facts_blend_example
  #NOTE: we will manage join critieria in sql_always_where.
  #Not sure one to one can be assumed here... if facts don't have same keys... we'd have to roll them up to this grain...
  join: user_order_facts {
    relationship:one_to_many
    # type:cross
    type: full_outer
    # sql_on:${blending_facts.dynamic_join_criteria};;
    sql_on:
    {% if user_order_facts.earlier_in_query_views._sql == '.REPLACE_ME_WITH_JOIN_FIELD_NAME,' %}TRUE
    {%else%}
      {% assign this_field = 'user_id' %}
      {% assign this_join_criteria = user_order_facts.earlier_in_query_views._sql | replace: 'REPLACE_ME_WITH_JOIN_FIELD_NAME', this_field %}
      coalesce({{this_join_criteria}} NULL)=user_order_facts.{{this_field}}
      and
      {% assign this_field = 'created_at_date' %}
      {% assign this_join_criteria = user_order_facts.earlier_in_query_views._sql | replace: 'REPLACE_ME_WITH_JOIN_FIELD_NAME', this_field %}
      coalesce({{this_join_criteria}} NULL)=user_order_facts.{{this_field}}
      --and ... more join criteria would go here
    {%endif%}
    ;;
  }
  join: user_session_facts {
    relationship:one_to_many
    # type:cross
    type: full_outer
    # sql_on:${blending_facts.dynamic_join_criteria};;
    sql_on:
    {% if user_session_facts.earlier_in_query_views._sql == '.REPLACE_ME_WITH_JOIN_FIELD_NAME,' %}TRUE
    {%else%}
    {% assign this_field = 'user_id' %}
    {% assign this_join_criteria = user_session_facts.earlier_in_query_views._sql | replace_first: '.REPLACE_ME_WITH_JOIN_FIELD_NAME,',''%}
    {% assign this_join_criteria = this_join_criteria | replace: 'REPLACE_ME_WITH_JOIN_FIELD_NAME', this_field %}
    coalesce({{this_join_criteria}} NULL)=user_session_facts.{{this_field}}
    and
    {% assign this_field = 'created_at_date' %}
    {% assign this_join_criteria = user_session_facts.earlier_in_query_views._sql | replace_first: '.REPLACE_ME_WITH_JOIN_FIELD_NAME,',''%}
    {% assign this_join_criteria = this_join_criteria | replace: 'REPLACE_ME_WITH_JOIN_FIELD_NAME', this_field %}
    coalesce({{this_join_criteria}} NULL)=user_session_facts.{{this_field}}
    --and ... more join criteria would go here
    {%endif%}
    ;;
  }
  join: in_query_tracker {sql:;;relationship:one_to_one}

  sql_always_where:
  1=1

  ;;
  # {% assign count_of_facts = 0 %}
  # {% if user_order_facts._in_query %}{% assign count_of_facts = count_of_facts | plus: 1 %}{%endif%}
  # {% if user_session_facts._in_query %}{% assign count_of_facts = count_of_facts | plus: 1 %}{%endif%}

  # {% if count_of_facts > 1 %}
  #   {% assign join_criteria_sql = '' %}

  #   {% assign this_field_join_criteria_sql = '' %}
  #   {% if user_order_facts._in_query %}{% assign this_field_join_criteria_sql = this_field_join_criteria_sql | append: ' = user_order_facts.user_id' %}{% endif %}
  #   {% if user_session_facts._in_query %}{% assign this_field_join_criteria_sql = this_field_join_criteria_sql | append: ' = user_session_facts.user_id' %}{% endif %}
  #   --more joins' fields would be added here
  #   {% assign this_field_join_criteria_sql = this_field_join_criteria_sql | remove_first: ' = '%}
  #   {% assign join_criteria_sql = join_criteria_sql | append: this_field_join_criteria_sql %}

  #   --second join field:
  #   {% assign join_criteria_sql = join_criteria_sql | append: ' and '%}

  #   {% assign this_field_join_criteria_sql = '' %}
  #   {% if user_order_facts._in_query %}{% assign this_field_join_criteria_sql = this_field_join_criteria_sql | append: ' = user_order_facts.created_at_date' %}{% endif %}
  #   {% if user_session_facts._in_query %}{% assign this_field_join_criteria_sql = this_field_join_criteria_sql | append: ' = user_session_facts.created_at_date' %}{% endif %}
  #   --more joins' fields would be added here
  #   {% assign this_field_join_criteria_sql = this_field_join_criteria_sql | remove_first: ' = '%}
  #   {% assign join_criteria_sql = join_criteria_sql | append: this_field_join_criteria_sql %}

  #   --more conformed dimension keys would be similarly added here

  #   and {{join_criteria_sql}}
  # {% endif %}
}
