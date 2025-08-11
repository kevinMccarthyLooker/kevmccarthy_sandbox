#copied from union all model example originaly built for Meli.
# Simplified by taking away some of the extra examples
# updating to use structs and looker views...

connection: "kevmccarthy_bq"
datagroup: marketplace_projects_standard_build_trigger {
  # We should try to establish a single common trigger criteria...
  sql_trigger: select current_date() ;; # need a query with one cell result where value changes exactly when we want to trigger.  If midnight is not the ideal time, This could check an etl table, or sql could be adjust such that the result value changes at exactly a certain time in the day (e.g. something like select date_trunc(timestamp_sub(current_timestamp(), interval 2 hours), day) ... to cause trigger at 2:00 am)
}
#     # - A principle/goal is to minimize processing and we have established that nightly batch processing will be sufficient across the entire initiative (ie current day data is not required).  We should not initiate more builds or bypass available cached results if we don't need to.
#     # - Using a single datagroup has the benefit that Looker will automatically manage build order based on dependencies of one build on other builds within a datagroup


## Below are basic/pre-existing foundational view definitions.  These are basically the minimal code versions of auto-generated lookml we'll get typically from source tables, and these views represent views defined elsewhere in Meli project irrespective of this intiiative.
view: users {
  sql_table_name:`bigquery-public-data.thelook_ecommerce.users` ;;
  dimension_group:  created_at     {type: time}
  dimension:        first_name     {}
  dimension:        last_name      {}
  dimension:        email          {}
  dimension:        age            {type: number}
  dimension:        gender         {}
  dimension:        state          {}
  dimension:        street_address {}
  dimension:        postal_code    {}
  dimension:        city           {}
  dimension:        country        {}
  dimension:        latitude       {type: number}
  dimension:        longitude      {type: number}
  dimension:        traffic_source {}
  dimension:        id             {type: number primary_key:yes}
  measure:          count          {type: count}
}

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

view: events {
  sql_table_name: `bigquery-public-data.thelook_ecommerce.events` ;;
  dimension_group:  created_at      {type: time}
  dimension:        user_id         {type: number}
  dimension:        sequence_number {type: number}
  dimension:        session_id      {}
  dimension:        ip_address      {}
  dimension:        city            {}
  dimension:        state           {}
  dimension:        postal_code     {}
  dimension:        browser         {}
  dimension:        traffic_source  {}
  dimension:        uri             {}
  dimension:        event_type      {}
  dimension:        id              {type: number primary_key:yes}
  measure:          count           {type: count}
}

## Below are foundational source explore definitions.  These represent existing Meli explores in which metrics and dimensions that will be used for this initiative already exist
explore: order_items {
  join: users {sql_on: ${order_items.user_id}=${users.id} ;; relationship: many_to_one}
}

explore: events {
  join: users {sql_on: ${events.user_id}=${users.id} ;; relationship: many_to_one}
}

view: events_data {
  #hide basic dimensions?  There could be a way to make them visible during development/troublshooting specifically

  #for use with extensions. use in base reference for this view, in place of ${TABLE}
  dimension: special_table_name {
    hidden: yes
    sql: source_data.events_data ;;
  }

  fields_hidden_by_default: yes
  #something that has to be set manually for consistent reference.
  # dimension: view__is_in_query {sql:{{events_data._in_query}};;}
  derived_table: {
    # Note: Explore source must be an existing explore in this model.  If source explores exist in other models, we should consider options and their implications, such as:
    # - Establish these PDTs in the respective source models and/or use project import to port the logic to the new target model.
    # - Use publish_as_db_view (https://cloud.google.com/looker/docs/reference/param-view-publish-as-db-view parameter) to ensure that subsequent sql query(s) for blending data can find the table's location ( I expect ${[derived_tables_view_name].SQL_TABLE_NAME} will not work)

    explore_source: events {

      column: date_date {field:events.created_at_date} # Pull each applicable date grain separately (rather than pull date and then group up from there with dimension_group... because we may not have date level detail.
      column: date_month {field:events.created_at_month}

      column: country {field:users.country} # (Common_Dimensions_1) 'user_country' field is pulled from every source explore where it is available/applicable
      column: age {field:users.age}

      #bring in relevant columns from this source
      column: browser {field:events.browser}

      column: count {field:events.count}
    }
    datagroup_trigger: marketplace_projects_standard_build_trigger
#     datagroup: marketplace_projects_standard_build_trigger { # We should try to establish a single common trigger criteria...
# #     #   sql_trigger: select current_date() ;; # need a query with one cell result where value changes exactly when we want to trigger.  If midnight is not the ideal time, This could check an etl table, or sql could be adjust such that the result value changes at exactly a certain time in the day (e.g. something like select date_trunc(timestamp_sub(current_timestamp(), interval 2 hours), day) ... to cause trigger at 2:00 am)
# #     # }
    partition_keys: ["date_date"]
  }
  # dimension: source {sql:${special_table_name}.source;;}
  dimension: date_date {type:date sql:${special_table_name}.date_date;;}
  dimension: date_month {type:date_month sql:${special_table_name}.date_month;;}
  dimension: country {sql:${special_table_name}.country;;}
  dimension: age {sql:${special_table_name}.age;;}
  dimension: browser {sql:${special_table_name}.browser;;}
  # {sql:source_data.events_data.browser;;}
  # {
  #   sql:@{blend_special_source_table_basic_column_reference};;
  #   }
  dimension: count {sql:${special_table_name}.count;;}

  #unhide measures
  measure: total_events_count {hidden:no
    type: sum
    sql: ${count}),0) * nullif(sum(${count}),0) / nullif(sum(${count};;
  }
}


# view: order_items_blend {
#   dimension: date_month { type:date_month }
#   dimension: status {
#     # sql: ${TABLE}.status ;;
#   }
#   dimension: country {}
#   dimension: order_items_count {hidden:yes sql:${TABLE}.count;;}
#   measure: total_order_items_count {type: sum sql: ${order_items_count} ;;}
# }

# Note - parameters and considerations explained in similar steps above are not repeated
# view: for_extension {

# }
view: order_items_data {
  dimension: special_table_name {
    hidden: yes
    sql: source_data.order_items_data ;;
  }
  fields_hidden_by_default: yes

  # dimension: view__is_in_query {sql:{{order_items_data._in_query}};;}
  # extends: [for_extension]
  derived_table: {
    explore_source: order_items {

      # derived_column: date_date                 {sql: cast(null as timestamp) ;;}       # (DATE_1) source doesn't have date level detail so we explicitly push null.  avoid type clash in subsequent union by casting missing/null fields to match to existing datatype from other sources.
      derived_column: date_date                 {sql: date_month ;;}       # (DATE_1) source doesn't have date level detail so we explicitly push null.  avoid type clash in subsequent union by casting missing/null fields to match to existing datatype from other sources.
      column:         date_month                {field:order_items.created_at_month}

      column:         country              {field:users.country}
      column:         age                  {field:users.age}

      column:         status              {field:order_items.status}

      column:         count         {field: order_items.count}
    }
    datagroup_trigger: marketplace_projects_standard_build_trigger
    partition_keys: ["date_date"]
  }
  dimension: source {sql:${special_table_name}.source;;}
  # dimension: date_date {type:date} #purposefully don't have this dimension
  dimension: date_month {type:date_month sql:${special_table_name}.date_month;;}
  dimension: country {sql:${special_table_name}.country;;}
  dimension: age {type:number sql:${special_table_name}.age;;}
  dimension: status {
    sql: ${special_table_name}.status ;;
    # sql:@{blend_special_source_table_basic_column_reference};;
    }

  # dimension: status {sql:{% if  view__is_in_query._sql=='true' %}{{_field._name}}{%else%}null/*sql replaced with null because the view {{_view._name}} is not required by the query (e.g. no metrics)*/{%endif%};;}


  dimension: count {sql:${special_table_name}.count;;}

  #unhide measures
  measure: total_order_items_count {hidden:no
    type: sum
    #goal: avoid colaescing sums to 0
    sql: ${count}),0) * nullif(sum(${count}),0) / nullif(sum(${count};;
  }
  # measure: total_order_items_count_regular {
  #   type: sum
  #   sql: ${count};;
  # }

  measure: row_count {group_label:"troubleshooting" type:count}
}





view: blended_data {

   #We should be able to avoid having one specific starting table.  This is a minmal starting table with no impact
  #   sql: (select null limit 0) ;;}

  #We'll generate a union of different datasets.  We will keep data in separate structs, so we can reference them like tables and so we can manage union syntax.
  #We want core date fields and other fields we need to optimize for in the main/initial part of the union.  Note for example that we don't get benefit of partitions if dates have been coalesced, we do if they are unioned
  # sql_table_name:(select null as source, null as date_date,null as events_data, null as order_items_data from (select null) ;;

  # We may have different 'versions' of the data to display (e.g. for period over period), so have a layer at that level as well.

#8/11 want to use ctes
derived_table: {
  sql:
with blended as
(
select events_data, order_items_data from
(select * from ${events_data.SQL_TABLE_NAME} as events_data) events_data
  full outer join
(select * from ${order_items_data.SQL_TABLE_NAME} as order_items_data) order_items_data on false
)
--uniuque sources unioned to allow for different structs and create namespaces for additional and 'duplicate' data structure
--unioninig on a specific date enables partition optimization
,unioned as (
          select date(events_data.date_date) as date_date     ,events_data         ,null as order_items_data from blended
union all select date(order_items_data.date_date) as date_date, null as events_data, order_items_data from blended
)

,versions as (
select            'current' as version_label,date_date as date_date, unioned as source_data, case when 1 = 0 then unioned else null end as yoy, case when 1=0 then unioned else null end as running_total  from unioned


{% if events_data_yoy._in_query or order_items_data_yoy._in_query or this_explore_cross_view_fields_yoy._in_query %}
  union all select 'yoy' as period,date_add(unioned.date_date, interval 1 YEAR) as date_date,case when 1 = 0 then unioned else null end as source_data, unioned as yoy, case when 1=0 then unioned else null end as running_total from unioned
    where {% condition date_date %} date_add(unioned.date_date, interval 1 YEAR) {% endcondition %}
{% endif %}


{% if events_data_running_total._in_query or order_items_data_running_total._in_query %}
union all
  select 'running total days' as version_label,date_add(date_date, interval number DAY) as date_date,case when 1 = 0 then unioned else null end as source_data, case when 1=0 then unioned else null end as yoy, unioned as running_total
    from unioned left join unnest((select generate_array(0,{{explore_params.selected_number_of_days_for_running_total._sql}}))) number
where  date_add(date_date, interval {{explore_params.selected_number_of_days_for_running_total._sql}}  DAY) >{% date_start date_date  %}
and date_date<{% date_end date_date  %}
{% endif %}

)

select * from versions

  ;;
}

dimension: version_label {}
  measure: version_labels_on_row {
    type: string
    sql: string_agg(distinct ${version_label}) ;;
  }
measure: date_date_range_included {
  type: string
  sql: concat(min(${date_date}),' - ',max(${date_date})) ;;
}
  measure: date_raw_range_included {
    type: string
    sql: concat(min(yoy.date_date),' - ',max(source_data.date_date)) ;;
  }
# dimension: period {}
#   sql_table_name:
# (select * from
# (

# --Source, Version, Key Date Field, [other key fields present everywhere] , [series of structs for source, version etc]
# {% assign source_names = "events_data" | split: ";" %}
# {% assign order_items_data_source_name = "order_items_data" | split: ";" %}
# --sourcenames:{{source_names}}
# {% assign source_namesv2 = source_names | concat: order_items_data_source_name | join:',' |append:','%}
# --source_namesv2:{{source_namesv2}}
# {% assign source_namesv3 = source_namesv2 | replace: ',','_yoy,'%}
# --source_namesv3:{{source_namesv3}}
# {% assign source_namesv4 = source_namesv2 | append: source_namesv3 %}
# --source_namesv4:{{source_namesv4}}
# {% assign source_names_final = source_namesv4 %}
# --source_names_final:{{source_names_final}}
# {% assign final_array = source_names_final | split: ',' %}
# --final_array{{final_array}}
# --primary sources:

# {% assign empty_structs_sql = '' %}
# {% for source_name in final_array %}
#   {% assign empty_structs_sql = empty_structs_sql | append: 'null as ' | append: source_name | append:', ' %}
# {% endfor %}

# {% assign full_union_schema ='select string(null) as source, date(null) as date_date, ' | append: empty_structs_sql | append:' from (select null)' %}
# --full_union_schema{{full_union_schema}}
# {%- assign source_sql = '' %}
# {% assign source_sql = source_sql | append: full_union_schema %}

# --source_sql log1--
# /*
# {{source_sql}}
# */
# {% if events_data._in_query %}
# {% assign source_to_process = 'events_data,' %}
# {% assign replacements_sql = 'null as ' | append: source_to_process %}
# {% assign this_source_sql = "
# union all select '"
#   | append: source_to_process | append: "' as source, date(date_date) as date_date, " | append: empty_structs_sql | replace: replacements_sql, source_to_process  %}
# {% assign this_source_sql = this_source_sql | split: '' | reverse | join:'' |remove_first:','|split:''|reverse|join:''%}
# {% assign this_source_sql = this_source_sql | append: 'from ${events_data.SQL_TABLE_NAME} as ' | append:  source_to_process |append:'
#   '%}

# {%comment%} remove final comma {% endcomment %}
# {% assign this_source_sql = this_source_sql | split: '' | reverse | join:'' |remove_first:','|split:''|reverse|join:''%}
# {% endif %}

# {% assign source_sql = source_sql | append: this_source_sql %}
# {% if order_items_data._in_query %}
#   {% assign source_to_process = 'order_items_data,' %}
#   {% assign replacements_sql = 'null as ' | append: source_to_process %}
#   {% assign this_source_sql = "
# union all select 'order_items_data' as source, date(date_date) as date_date," | append: empty_structs_sql  | replace: replacements_sql, source_to_process  %}
#   {% assign this_source_sql = this_source_sql | split: '' | reverse | join:'' |remove_first:','|split:''|reverse|join:''%}
#   {% assign this_source_sql = this_source_sql | append: 'from ${order_items_data.SQL_TABLE_NAME} as ' | append:  source_to_process %}
#   {% assign this_source_sql = this_source_sql | split: '' | reverse | join:'' |remove_first:','|split:''|reverse|join:''%}
# {% endif %}
# {% assign source_sql = source_sql | append: this_source_sql %}

# {% if events_data_yoy._in_query %}
#   {% assign source_to_process = 'events_data_yoy,' %}
#   {% assign replacements_sql = 'null as ' | append: source_to_process %}
#   {% assign this_source_sql = "
# union all select 'events_data_yoy' as source, date_add(date(date_date), interval 1 YEAR) as date_date," | append: empty_structs_sql  | replace: replacements_sql, source_to_process  %}
#   {% assign this_source_sql = this_source_sql | split: '' | reverse | join:'' |remove_first:','|split:''|reverse|join:''%}
#   {% assign this_source_sql = this_source_sql | append: 'from ${events_data.SQL_TABLE_NAME} as ' | append:  source_to_process %}
#   {% assign this_source_sql = this_source_sql | split: '' | reverse | join:'' |remove_first:','|split:''|reverse|join:''%}
# {% endif %}
# {% assign source_sql = source_sql | append: this_source_sql %}

# {% if order_items_data_yoy._in_query %}
#   {% assign source_to_process = 'order_items_data_yoy,' %}
#   {% assign replacements_sql = 'null as ' | append: source_to_process %}
#   {% assign this_source_sql = "
# union all select 'order_items_data_yoy' as source, date_add(date(date_date), interval 1 YEAR) as date_date," | append: empty_structs_sql  | replace: replacements_sql, source_to_process  %}
#   {% assign this_source_sql = this_source_sql | split: '' | reverse | join:'' |remove_first:','|split:''|reverse|join:''%}
#   {% assign this_source_sql = this_source_sql | append: 'from ${order_items_data.SQL_TABLE_NAME} as ' | append:  source_to_process %}
#   {% assign this_source_sql = this_source_sql | split: '' | reverse | join:'' |remove_first:','|split:''|reverse|join:''%}
# {% endif %}

# {% assign source_sql = source_sql | append: this_source_sql %}
# {{source_sql}}

# ----
# )

#   ;;
#   # events_data as events_data, null as order_items_data, null as events_yoy from ${events_data.SQL_TABLE_NAME}  as events_data
#   # string(null) as source,date(null) as date_date, null as events_data, null as order_items_data, null as events_yoy
# # (
# # --Source, Version, Key Date Field, [other key fields present everywhere] , [series of structs for source, version etc]
# #   select string(null) as source,date(null) as date_date, null as events_data, null as order_items_data from (select null)
# #   {% if events_data._in_query %}
# #   union all select 'events' as source, date(date_date), events_data as events_data, null as order_items_data from ${events_data.SQL_TABLE_NAME}  as events_data
# #   {% endif %}
# #   {% if order_items_data._in_query %}
# #   union all select 'events' as source, date(date_date), null as events_data, order_items_data as order_items_data from ${order_items_data.SQL_TABLE_NAME}  as order_items_data
# #   {% endif %}
# # )


# #   derived_table: {
# #     # sql:
# #     # select
# #     #   events_blend,
# #     #   order_items_blend,
# #     #   coalesce(events_blend.date_date,order_items_blend.date_date) as date_date,
# #     #   coalesce(events_blend.date_month,order_items_blend.date_month) as date_month
# #     #   from
# #     #   (select 'events' as source,* from ${events_data.SQL_TABLE_NAME}) as events_blend
# #     #   full outer join
# #     #   (select 'order_items' as source,* from ${order_items_data.SQL_TABLE_NAME}) as order_items_blend on false

# # #Confirmed we can write in_query checks correctly here... but not sure the join references really matter unless the compoents are used
# #     #   ;;
# #     sql:
# #     select
# #     events_blend,
# #     order_items_blend,
# #     coalesce(events_blend.date_date,order_items_blend.date_date) as date_date,
# #     coalesce(
# #       events_blend.date_month
# #       {% if order_items_blend._in_query %},order_items_blend.date_month{%endif%}
# #     ) as date_month
# #     from
# #     (select 'events' as source,* from ${events_data.SQL_TABLE_NAME}) as events_blend

# #     full outer join
# #     (select 'order_items' as source,* from ${order_items_data.SQL_TABLE_NAME}
# #     {% if order_items_blend._in_query %}{%else%} where false {%endif%}
# #     ) as order_items_blend on false


# #     ;;
# #   }



  # sql_table_name:  (select null as source, null as date_date,null as events_data, null as order_items_data from (select null) ;;
  # derived_table: {


####
# COALESCING
# need to coalesce the corresponding dimensions from every source (which has that data)
# using some advanced tricks here
# # 1) (WIP..) Suggestions explore.  Otherwise these tricks cause no suggestions to be returned.  Naive handling could lead to huge suggestion queries.
# # 2) By refering to the POTENTAL source field a respective view, we can fetch the relevant sql if it has been set, and if not set then we'll handle it logically and put a note in sql. avoids scanning data unnecessarily
# # 3) Note: a related step (but taken the source view side) handles the case where there IS sql for the dimension in that view, but we didn't actually need the view because no measures were set

  dimension: status {
    suggest_explore: blended_data_suggestions suggest_dimension: status
    # sql: @{blended_field_sql_lookup__alternate_string_label_for_nulls};;
    sql: @{blended_field_sql_lookup};;
  }

  dimension: source {sql: @{blended_field_sql_lookup};; }
###
# Expose the data elements we have made available in the bended dataset.
# This is the special partition field.
  dimension: date_date {
    group_label: "Dates"
    type:date
    datatype: date
    # sql: @{blended_field_sql_lookup};;
    sql:date_date;;
  }
  dimension: date_month {
    group_label: "Dates"
    type:date_month
    # sql: coalesce(${events_blend.date_month::date},${order_items_blend.date_month::date}) ;;
# sql: coalesce(
# null
# {%if events_data._in_query%}{{events_data.date_month._sql | prepend:',' | append: '/**/' | replace: ',/**/','/*no field found*/' }}{%else%}/*view not _in_query based on required metrics*/{%endif%}
# {%if order_items_data._in_query%}{{order_items_data.date_month._sql | prepend:',' | append: '/**/' | replace: ',/**/','/*no field found*/' }}{%else%}/*view not _in_query based on required metrics*/{%endif%}
# ) ;;
    sql: @{blended_field_sql_lookup};;
  }

#This example shows a way we will simply check every source view for the presence of this particular dimenions
  dimension: country {
    # {% assign field_name = 'country'%}
    # sql:
    # {% assign field_name = _field._name | split: '.' | last %}
    # {%assign final_sql = ''%}
    # {% for i in (1..5) %}
    # {% if i == 1 %} {% assign a_view = order_items_data %}
    # {% elsif i == 2 %} {% assign a_view = events_data %}
    # {% else %}{%break%}
    # {% endif %}
    # {% assign final_sql = final_sql | append: ',' | append: '/*(from:' | append: a_view._name | append: '-> */'| append: a_view[field_name]._sql %}
    # {% endfor %}
    # coalesce(null,{{final_sql}})
    # ;;
sql:
{%- assign field_name = _field._name | split: '.' | last -%}
{%- assign final_sql = '' -%}
{%- for i in (1..10) -%}
  {%- if i == 1 -%} {%- assign a_view = order_items_data_source -%}
  {%- elsif i == 2 -%} {%- assign a_view = events_data_source -%}
  {%- elsif i == 3 -%} {%- assign a_view = events_data_yoy -%}
  {%- elsif i == 4 -%} {%- assign a_view = order_items_data_yoy -%}
  {%- elsif i == 5 -%} {%- assign a_view = events_data_running_total -%}
  {%- elsif i == 6 -%} {%- assign a_view = order_items_data_running_total -%}
  {%- else -%}{%- break -%}
  {%- endif -%}
  {%- assign final_sql = final_sql | append: '@{newline}  ,/* from ' | append: a_view._name | append: '-> */' -%}
  {%- if  a_view[field_name]._sql == '' -%}
    {%- assign final_sql = final_sql | append: 'null /* ' | append: field_name | append: ' declaration not found in ' | append: a_view._name | append: ' */' -%}
  {%- else -%}
    {%- assign final_sql = final_sql | append: a_view[field_name]._sql -%}
  {%- endif -%}
{%- endfor -%}
{%- assign final_sql = final_sql | prepend: 'coalesce(null' | append: '@{newline})' -%}
{{- final_sql -}};;
  }

  dimension: browser {
    # description: "test - {{events_data.browser._sql | prepend:',' | append: '/**/' | replace: ',/**/','/*no field found*/' }}{{order_items_data.browser._sql | prepend:',' | append: '/**/' | replace: ',/**/','/*no field found*/' }}"
# sql:
# coalesce(
# null
# {%if events_data._in_query%}{{events_data.browser._sql | prepend:',' | append: '/**/' | replace: ',/**/','/*no field found*/' }}{%else%}/*view not _in_query based on required metrics*/{%endif%}
# {%if order_items_data._in_query%}{{order_items_data.browser._sql | prepend:',' | append: '/**/' | replace: ',/**/','/*no field found*/' }}{%else%}/*view not _in_query based on required metrics*/{%endif%}
# ) ;;
    sql:
    {%- assign field_name = _field._name | split: '.' | last -%}
    {%- assign final_sql = '' -%}
    {%- for i in (1..10) -%}
    {%- if i == 1 -%} {%- assign a_view = order_items_data_source -%}
    {%- elsif i == 2 -%} {%- assign a_view = events_data_source -%}
    {%- elsif i == 3 -%} {%- assign a_view = events_data_yoy -%}
    {%- elsif i == 4 -%} {%- assign a_view = order_items_data_yoy -%}
    {%- elsif i == 5 -%} {%- assign a_view = events_data_running_total -%}
  {%- elsif i == 6 -%} {%- assign a_view = order_items_data_running_total -%}
    {%- else -%}{%- break -%}
    {%- endif -%}
    {%- assign final_sql = final_sql | append: '@{newline}  ,/* from ' | append: a_view._name | append: '-> */' -%}
    {%- if  a_view[field_name]._sql -%}
      {%- assign final_sql = final_sql | append: a_view[field_name]._sql -%}
    {%- else -%}
      {%- assign final_sql = final_sql | append: 'null /* ' | append: field_name | append: ' declaration not found in ' | append: a_view._name | append: ' */' -%}
    {%- endif -%}
    {%- endfor -%}
    {%- assign final_sql = final_sql | prepend: 'coalesce(null' | append: '@{newline})' -%}
    {{- final_sql -}};;
  }

}

# view: order_items_data_yoy {
#   extends: [order_items_data]
#   # sql_table_name: (${events_data.SQL_TABLE_NAME}) ;;
#   sql_table_name: ;; #don't want to re-persist the base sql
# }

view: this_explore_cross_view_fields {
  measure: events_per_item {
    type: number
    sql: safe_divide(${events_data_source.total_events_count},${order_items_data_source.total_order_items_count}) ;;
  }
}
view: this_explore_cross_view_fields_yoy {
  extends: [this_explore_cross_view_fields]
  measure: events_per_item {
    sql: safe_divide(${events_data_yoy.total_events_count},${order_items_data_yoy.total_order_items_count}) ;;
  }

}


# view: events_data_yoy {
#   extends: [events_data]
#   # sql_table_name: (${events_data.SQL_TABLE_NAME}) ;;
#   sql_table_name: ;; #don't want to re-persist the base sql
# }

view: events_data_source {
  extends: [events_data]
  # sql_table_name: (${events_data.SQL_TABLE_NAME}) ;;
  sql_table_name: source_data.events_data;; #don't want to re-persist the base sql
}
view: events_data_yoy {
  extends: [events_data]
  # sql_table_name: (${events_data.SQL_TABLE_NAME}) ;;
  # sql_table_name:yoy.events_data ;; #don't want to re-persist the base sql
  dimension: special_table_name {
    hidden: yes
    sql: yoy.events_data ;;
  }
}
view: events_data_running_total {
  extends: [events_data]
  dimension: special_table_name {
    hidden: yes
    sql: running_total.events_data ;;
  }


}

view: order_items_data_source {
  extends: [order_items_data]
  # sql_table_name: source_data.order_items_data ;;
  dimension: special_table_name {
    hidden: yes
    sql: source_data.order_items_data ;;
  }
}
view: order_items_data_yoy {
  extends: [order_items_data]
  # sql_table_name: yoy.order_items_data ;;
  dimension: special_table_name {
    hidden: yes
    sql: yoy.order_items_data ;;
  }
}
view: order_items_data_running_total {
  extends: [order_items_data]
  dimension: special_table_name {
    hidden: yes
    sql: running_total.order_items_data ;;
  }
}



view: explore_params {
  parameter: allow_future_data {type:yesno}
  parameter: running_total_number_of_days {type: number default_value: "7"}
  dimension: selected_number_of_days_for_running_total {hidden: yes sql:/*test*/{{  running_total_number_of_days._parameter_value }};;}
}

view: closing_paren {}
explore: blended_data {

  sql_always_where:
  --explore_params.allow_future_data:{{explore_params.allow_future_data._parameter_value}}--
  {% if explore_params.allow_future_data._parameter_value == "true" %}1=1{%else%}${date_date} < current_date() {%endif%} ;;
  join: explore_params {sql:  ;; relationship:one_to_one}
  # join: events_data {
  #   # sql:union all select 'events' as source, date_date,${events_data.SQL_TABLE_NAME} as events_data, null as order_items_data from ${events_data.SQL_TABLE_NAME} ;;relationship:one_to_one
  #   sql:  ;; relationship:one_to_one


  # join: order_items_data {
  #   # sql:union all select 'order_items' as source,date_date,null as events_data,${order_items_data.SQL_TABLE_NAME} as order_items_data from ${order_items_data.SQL_TABLE_NAME};;relationship:one_to_one
  #   sql:  ;; relationship:one_to_one
  # }
  join: events_data_source {# sql:union all select 'events' as source, date_date,${events_data.SQL_TABLE_NAME} as events_data, null as order_items_data from ${events_data.SQL_TABLE_NAME} ;;relationship:one_to_one
    sql:  ;; relationship:one_to_one
  }
  join: events_data_yoy {sql:  ;; relationship:one_to_one}
  join: events_data_running_total {sql:  ;; relationship:one_to_one}
  join: order_items_data_source {sql:  ;; relationship:one_to_one}
  join: order_items_data_yoy {sql:  ;; relationship:one_to_one}
  join: order_items_data_running_total {sql:  ;; relationship:one_to_one}



  join: this_explore_cross_view_fields {sql:  ;; relationship:one_to_one}
  join: this_explore_cross_view_fields_yoy {sql:  ;; relationship:one_to_one}




  #keep this at end of explore definition. i
  # always_join: [closing_paren]
  # join: closing_paren {sql:)/*end union all*/ ;;relationship:one_to_one}

  # join: yoy_data {
  #   # sql:union all select 'order_items' as source,date_add(date_date, interval 1 year) as date_date,null as events_data,${order_items_data.SQL_TABLE_NAME} as order_items_data from ${order_items_data.SQL_TABLE_NAME};;relationship:one_to_one
  #   sql: union all select 'yoy' source,date_add(date_date, interval 1 year) as date_date,events_data,order_items_data from blended_data ;;
  # }
  #/*sql_always_having would be the last chance to interact with sql.  But it blocke certain types of filtering*/
  sql_always_having: 1=1 ;;
  #/*<- LookML IDE Formatting fix
  # ) as t3 where blended_data_date_date = current_date()
}



#####
# Need to deal with suggestions
#Suggestions##
# view: blended_data_suggestions {
#   derived_table: {
#     explore_source: blended_data {
#       column: status {field:blended_data.status}
#       #bring in measure to force source tables to be brought in
#       column: total_events_count {field: events_data_source.total_events_count}
#       column: total_order_items_count {field: order_items_data.total_order_items_count}
#     }
#   }
#   dimension: status {}
# }
# explore: blended_data_suggestions {}
