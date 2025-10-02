
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
          ,row_number() over() as generated_primary_key
FROM `bigquery-public-data.thelook_ecommerce.order_items` AS order_items
LEFT JOIN `bigquery-public-data.thelook_ecommerce.orders` AS orders ON order_items.order_id=orders.order_id
GROUP BY ALL;;
  }
  dimension: generated_primary_key {primary_key:yes}
  dimension_group: created_at_date {type: time timeframes: [date,month,year] datatype: date}
  dimension: user_id {}
  dimension: product_id {}
  dimension: total_sale_price__dimension {sql:${TABLE}.total_sale_price;;type:number}
  measure:total_sale_price {type:sum sql:${total_sale_price__dimension};;}
  dimension: total_sales_completed__dimension {sql:${TABLE}.total_sales_completed;;type:number}
  measure:total_sales_completed {type:sum sql:${total_sales_completed__dimension};;}
}

view: user_session_facts {
  derived_table: {
    sql: SELECT
          (DATE(events.created_at )) AS created_at_date
          ,events.user_id  AS user_id
          ,events.session_id  AS session_id
          ,COUNT(*) AS events_count
          ,row_number() over() as generated_primary_key
        FROM `bigquery-public-data.thelook_ecommerce.events` events
        GROUP BY all;;
  }
  dimension: generated_primary_key {primary_key:yes}
  dimension_group: created_at_date {type: time timeframes: [date,month,year] datatype: date}
  dimension: user_id {}
  dimension: session_id {}
  dimension: events_count_dimension {sql:${TABLE}.events_count;; type:number}
  measure: total_events_count {type:sum sql:${events_count_dimension};;}
}

view: empty_base_for_facts_blend_example {
  derived_table: {sql:select null;;}
#   dimension: dynamic_join_criteria {
# sql:
#   {% assign join_criteria_sql = '' %}
#   {% assign count_of_facts = 0 %}
#   {% if user_order_facts._in_query %}{% assign count_of_facts = count_of_facts | plus: 1 %}{%endif%}
#   {% if user_session_facts._in_query %}{% assign count_of_facts = count_of_facts | plus: 1 %}{%endif%}
#   {% if count_of_facts <= 1 %}
#     true -- resolve to full outer join from empty_base to the only one actual table on true
#   {% elsif count_of_facts > 1 %}
#     --multiple facts are involved.  Want to align rows with join criteria matching corresponding joinable fields from all facts, and use with full outer join
#     --introduce keys from the first possibly joined fact table
#     {% assign this_field_join_criteria_sql = '' %}
#     {% if user_order_facts._in_query %}{% assign this_field_join_criteria_sql = this_field_join_criteria_sql | append: ' = user_order_facts.user_id' %}{% endif %}
#     {% if user_session_facts._in_query %}{% assign this_field_join_criteria_sql = this_field_join_criteria_sql | append: ' = user_session_facts.user_id' %}{% endif %}
#     --more joins' fields would be added here
#     {% assign this_field_join_criteria_sql = this_field_join_criteria_sql | remove_first: ' = '%}
#     {% assign join_criteria_sql = join_criteria_sql | append: this_field_join_criteria_sql %}

#     --introduce keys from the second possibly joined fact table
#     {% assign join_criteria_sql = join_criteria_sql | append: ' and '%}

#     {% assign this_field_join_criteria_sql = '' %}
#     {% if user_order_facts._in_query %}{% assign this_field_join_criteria_sql = this_field_join_criteria_sql | append: ' = user_order_facts.created_at_date' %}{% endif %}
#     {% if user_session_facts._in_query %}{% assign this_field_join_criteria_sql = this_field_join_criteria_sql | append: ' = user_session_facts.created_at_date' %}{% endif %}
#     --more joins' fields would be added here
#     {% assign this_field_join_criteria_sql = this_field_join_criteria_sql | remove_first: ' = '%}
#     {% assign join_criteria_sql = join_criteria_sql | append: this_field_join_criteria_sql %}

#     --more conformed dimension keys would be similarly added here
#     --handling likely needs adjusting for 3+ fact tables... this implies we'd end up with f1.a=f2.a=f3.a... logic yet to be completed described below
#     -- -- Will need to get from f1.a=f2.a=f3.a to f1.a=f2.a and f2.a=f3.a...
#     -- -- Approach in mind:
#     -- -- -- 1) make a string array by splitting on '=',
#     -- -- -- 2) for all view names except first and last...
#     -- -- -- -- replace:=view_name_var.field_name  with  =view_name_var.field_name and view_name_var.field_name
# {% endif %}
# {{join_criteria_sql}}
# ;;
#   }
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
  # dimension:earlier_in_query_views {
  #   sql: {%- assign this_view_name = 'user_order_facts' -%}
  #   {%- assign result_sql = in_query_tracker.join_criteria_template._sql | split: this_view_name | first -%}
  #   {{- result_sql -}}
  #   ;;
  # }
  # dimension:earlier_in_query_views {
  #   sql: {%- assign this_view_name = 'user_order_facts' -%}
  #         {%- assign result_sql = in_query_tracker.join_criteria_template._sql | split: this_view_name | first | replace: ',','.REPLACE_ME_WITH_JOIN_FIELD_NAME,'-%}
  #         {{- result_sql -}}
  #         ;;
  # }
  dimension:earlier_in_query_views {
    # sql:{%- assign result_sql = in_query_tracker.join_criteria_template._sql | split: _view._name | first | strip -%}{{- result_sql -}};;
    # sql:{{- in_query_tracker.join_criteria_template._sql | split: _view._name | first | strip -}};;
    # sql:{{- in_query_tracker.in_query_tracker._sql | split: _view._name | first | replace: ',','.REPLACE_ME_WITH_JOIN_FIELD_NAME,' | strip -}};;
    sql:{{- in_query_tracker.in_query_tracker._sql | split: _view._name | first | strip -}};;
    }
}
view: +user_session_facts {
  dimension:earlier_in_query_views {
    # {%- assign this_view_name = 'user_session_facts' -%}
    # {%- assign this_view_name = _view._name -%}
    # {%- assign result_sql = in_query_tracker.join_criteria_template._sql | split: this_view_name | first -%}
    sql:{%- assign result_sql = in_query_tracker.join_criteria_template._sql | split: _view._name | first | strip -%}{{ result_sql }};;
  }
}

view: coalesced_keys {
#   dimension: lct_nbr {
# sql:  COALESCE(
#         {% if i0133a_wk_pgp_smy_NL._in_query %}(i0133a_wk_pgp_smy_NL.lct_nbr){%else%}null{%endif%},
#         {% if i0114g_bgt_lct_pgp_NL._in_query %}(i0114g_bgt_lct_pgp_NL.lct_nbr){%else%}null{%endif%},
#         {% if i0193a_lct_pgp_inv_smy_NL._in_query %}(i0193a_lct_pgp_inv_smy_NL.lct_nbr){%else%}null{%endif%}
#       ) = (COALESCE(${dim_location_current.lct_nbr},0));;
#   }
#   dimension: prd_grp_nbr {
# sql:  COALESCE(
#         {% if i0133a_wk_pgp_smy_NL._in_query %}(i0133a_wk_pgp_smy_NL.prd_grp_nbr){%else%}null{%endif%},
#         {% if i0114g_bgt_lct_pgp_NL._in_query %}(i0114g_bgt_lct_pgp_NL.prd_grp_nbr){%else%}null{%endif%},
#         {% if i0193a_lct_pgp_inv_smy_NL._in_query %}(i0193a_lct_pgp_inv_smy_NL.prd_grp_nbr){%else%}null{%endif%}
#       ) = ${dim_item_hierarchy_pgp.prd_grp_nbr} ;;
#   }
#   dimension: fsc_wk_end_dt {
# sql:  COALESCE(
#         {% if i0133a_wk_pgp_smy_NL._in_query %}(DATE(i0133a_wk_pgp_smy_NL.fsc_wk_end_dt)){%else%}null{%endif%},
#         {% if i0114g_bgt_lct_pgp_NL._in_query %}(DATE(i0114g_bgt_lct_pgp_NL.fsc_wk_end_dt)){%else%}null{%endif%},
#         {% if i0193a_lct_pgp_inv_smy_NL._in_query %}(DATE(i0193a_lct_pgp_inv_smy_NL.fsc_wk_end_dt)){%else%}null{%endif%}
#       ) = ${i0036k_fsc_cal_cnv.fsc_wk_end_dt} ;;
#   }

  dimension: user_id {
    sql:
COALESCE(
  {% if user_order_facts._in_query %}user_order_facts.user_id{%else%}null{%endif%},
  {% if user_session_facts._in_query %}user_session_facts.user_id{%else%}null{%endif%}
)
    ;;
  }
  dimension: created_at_date {
    sql:
    COALESCE(
      {% if user_order_facts._in_query %}user_order_facts.created_at_date{%else%}null{%endif%},
      {% if user_session_facts._in_query %}user_session_facts.created_at_date{%else%}null{%endif%}
    )
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
    # sql_on:
    # /*user_order_facts.earlier_in_query_views._sql:{{user_order_facts.earlier_in_query_views._sql}}*/
    # {% if user_order_facts.earlier_in_query_views._sql == '.REPLACE_ME_WITH_JOIN_FIELD_NAME,' %}TRUE
    # {%else%}
    #   {% assign this_field = 'user_id' %}
    #   {% assign this_join_criteria = user_order_facts.earlier_in_query_views._sql | replace: 'REPLACE_ME_WITH_JOIN_FIELD_NAME', this_field %}
    #   coalesce({{this_join_criteria}} NULL)=user_order_facts.{{this_field}}
    #   and
    #   {% assign this_field = 'created_at_date' %}
    #   {% assign this_join_criteria = user_order_facts.earlier_in_query_views._sql | replace: 'REPLACE_ME_WITH_JOIN_FIELD_NAME', this_field %}
    #   coalesce({{this_join_criteria}} NULL)=user_order_facts.{{this_field}}
    #   --and ... more join criteria would go here
    # {%endif%}
    # ;;
    sql_on:
    /*user_order_facts.earlier_in_query_views._sql:{{user_order_facts.earlier_in_query_views._sql}}*/
    {% if user_order_facts.earlier_in_query_views._sql == ',' %}TRUE
    {%else%}
    {% assign this_field = 'user_id' %}
    {% assign this_field_with_dot_prefix_and_comma_suffix = '.' | append: this_field | append: ',' %}
    {% assign this_join_criteria = user_order_facts.earlier_in_query_views._sql | replace: ',', this_field_with_dot_prefix_and_comma_suffix %}
    coalesce({{this_join_criteria}} NULL)=user_order_facts.{{this_field}}
    and
    {% assign this_field = 'created_at_date' %}
    {% assign this_field_with_dot_prefix_and_comma_suffix = '.' | append: this_field | append: ',' %}
    {% assign this_join_criteria = user_order_facts.earlier_in_query_views._sql | replace: ',', this_field_with_dot_prefix_and_comma_suffix %}
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
#     sql_on:
# /* test: {% if user_order_facts._in_query %}yes, in query    {%endif%}*/
#     {% if user_session_facts.earlier_in_query_views._sql == '.REPLACE_ME_WITH_JOIN_FIELD_NAME,' %}TRUE
#     {%else%}
#     {% assign this_field = 'user_id' %}
#     {% assign this_join_criteria = user_session_facts.earlier_in_query_views._sql | replace_first: '.REPLACE_ME_WITH_JOIN_FIELD_NAME,',''%}
#     {% assign this_join_criteria = this_join_criteria | replace: 'REPLACE_ME_WITH_JOIN_FIELD_NAME', this_field %}
#     coalesce({{this_join_criteria}} NULL)=user_session_facts.{{this_field}}
#     and
#     {% assign this_field = 'created_at_date' %}
#     {% assign this_join_criteria = user_session_facts.earlier_in_query_views._sql | replace_first: '.REPLACE_ME_WITH_JOIN_FIELD_NAME,',''%}
#     {% assign this_join_criteria = this_join_criteria | replace: 'REPLACE_ME_WITH_JOIN_FIELD_NAME', this_field %}
#     coalesce({{this_join_criteria}} NULL)=user_session_facts.{{this_field}}
#     --and ... more join criteria would go here
#     {%endif%}
#     ;;
sql_on:
    {{coalesced_keys.user_id._sql         | split: 'user_session_facts' | first | append:'null)'}}=${user_session_facts.user_id}
and {{coalesced_keys.created_at_date._sql | split: 'user_session_facts' | first | append:'null)'}}=${user_session_facts.created_at_date_date}
    ;;
  }
  join: in_query_tracker {sql:;;relationship:one_to_one}
  join: coalesced_keys {sql:;;relationship:one_to_one}

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
