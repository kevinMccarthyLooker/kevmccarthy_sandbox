#copied from union all model example originaly built for Meli.
# Simplified by taking away some of the extra examples
# updating to use structs and looker views...

connection: "kevmccarthy_bq"

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
  fields_hidden_by_default: yes
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
  }
  dimension: source {sql:${TABLE}.source;;}
  dimension: date_date {type:date}
  dimension: date_month {type:date_month}
  dimension: country {}
  dimension: age {}
  dimension: browser {}
  dimension: count {}

  #unhide measures
  measure: total_events_count {hidden:no type: sum sql: ${count} ;;}
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
view: order_items_data {
  derived_table: {
    explore_source: order_items {

      # derived_column: date_date                 {sql: cast(null as timestamp) ;;}       # (DATE_1) source doesn't have date level detail so we explicitly push null.  avoid type clash in subsequent union by casting missing/null fields to match to existing datatype from other sources.
      column:         date_month                {field:order_items.created_at_month}

      column:         country              {field:users.country}
      column:         age                  {field:users.age}

      column:         status              {field:order_items.status}

      column:         count         {field: order_items.count}
    }
  }
  dimension: source {sql:${TABLE}.source;;}
  # dimension: date_date {type:date} #purposefully don't have this dimension
  dimension: date_month {type:date_month}
  dimension: country {}
  dimension: age {}
  dimension: status {}
  dimension: count {}

  #unhide measures
  measure: total_order_items_count {hidden:no type: sum sql: ${count} ;;}

}




###
# Step 3: Co-locate/align/blend the data from different sources, building upon the datasets prepared in Step 2, using a sql union.
# 8/1: Updating final union to be dynamic and not persisted
view: blended_data {
#   derived_table: {
#     # sql:
#     # select
#     #   events_blend,
#     #   order_items_blend,
#     #   coalesce(events_blend.date_date,order_items_blend.date_date) as date_date,
#     #   coalesce(events_blend.date_month,order_items_blend.date_month) as date_month
#     #   from
#     #   (select 'events' as source,* from ${events_data.SQL_TABLE_NAME}) as events_blend
#     #   full outer join
#     #   (select 'order_items' as source,* from ${order_items_data.SQL_TABLE_NAME}) as order_items_blend on false

# #Confirmed we can write in_query checks correctly here... but not sure the join references really matter unless the compoents are used
#     #   ;;
#     sql:
#     select
#     events_blend,
#     order_items_blend,
#     coalesce(events_blend.date_date,order_items_blend.date_date) as date_date,
#     coalesce(
#       events_blend.date_month
#       {% if order_items_blend._in_query %},order_items_blend.date_month{%endif%}
#     ) as date_month
#     from
#     (select 'events' as source,* from ${events_data.SQL_TABLE_NAME}) as events_blend

#     full outer join
#     (select 'order_items' as source,* from ${order_items_data.SQL_TABLE_NAME}
#     {% if order_items_blend._in_query %}{%else%} where false {%endif%}
#     ) as order_items_blend on false


#     ;;
#   }
derived_table: {
  sql: (select null limit 0) ;;
}

  dimension: source {

    sql: coalesce(
      null
      {%if events_data._in_query%}{{events_data.source._sql | prepend:',' | append: '/**/' | replace: ',/**/','/*no field found*/' }}{%else%}/*view not _in_query based on required metrics*/{%endif%}
      {%if order_items_data._in_query%}{{order_items_data.source._sql | prepend:',' | append: '/**/' | replace: ',/**/','/*no field found*/' }}{%else%}/*view not _in_query based on required metrics*/{%endif%}
      ) ;;
  }
###
# Expose the data elements we have made available in the bended dataset.
  dimension: date_date {
    group_label: "Dates"
    type:date
  }
  dimension: date_month {
    group_label: "Dates"
    type:date_month
    # sql: coalesce(${events_blend.date_month::date},${order_items_blend.date_month::date}) ;;
sql: coalesce(
null
{%if events_data._in_query%}{{events_data.date_month._sql | prepend:',' | append: '/**/' | replace: ',/**/','/*no field found*/' }}{%else%}/*view not _in_query based on required metrics*/{%endif%}
{%if order_items_data._in_query%}{{order_items_data.date_month._sql | prepend:',' | append: '/**/' | replace: ',/**/','/*no field found*/' }}{%else%}/*view not _in_query based on required metrics*/{%endif%}
) ;;
  }

  dimension: user_country {
sql: coalesce(
null
{%if events_data._in_query%}{{events_data.country._sql | prepend:',' | append: '/**/' | replace: ',/**/','/*no field found*/' }}{%else%}/*view not _in_query based on required metrics*/{%endif%}
{%if order_items_data._in_query%}{{order_items_data.country._sql | prepend:',' | append: '/**/' | replace: ',/**/','/*no field found*/' }}{%else%}/*view not _in_query based on required metrics*/{%endif%}
) ;;
  }

  dimension: browser {
    description: "test - {{events_data.browser._sql | prepend:',' | append: '/**/' | replace: ',/**/','/*no field found*/' }}{{order_items_data.browser._sql | prepend:',' | append: '/**/' | replace: ',/**/','/*no field found*/' }}"
sql:
coalesce(
null
{%if events_data._in_query%}{{events_data.browser._sql | prepend:',' | append: '/**/' | replace: ',/**/','/*no field found*/' }}{%else%}/*view not _in_query based on required metrics*/{%endif%}
{%if order_items_data._in_query%}{{order_items_data.browser._sql | prepend:',' | append: '/**/' | replace: ',/**/','/*no field found*/' }}{%else%}/*view not _in_query based on required metrics*/{%endif%}
) ;;
  }
  dimension: status {
    suggest_explore: blended_data_suggestions suggest_dimension: status
    sql:
    coalesce(
    null
    {%if events_data._in_query%}{{events_data.status._sql | prepend:',' | append: '/**/' | replace: ',/**/','/*no field found*/' }}{%else%}/*view not _in_query based on required metrics*/{%endif%}
    {%if order_items_data._in_query%}{{order_items_data.status._sql | prepend:',' | append: '/**/' | replace: ',/**/','/*no field found*/' }}{%else%}/*view not _in_query based on required metrics*/{%endif%}
    ) ;;
  }
  #raw fields that will be re-aggregated into measures
  # dimension: order_items_count {hidden:yes}
  # dimension: events_count {hidden:yes sql:events.events_count;;}
  # dimension: total_new_users_count {hidden:yes}

  #measures
  # measure: total_order_items_count {type: sum sql: ${order_items_count} ;;}
  # measure: total_events_count {type: sum sql: ${events_count} ;;}
  # measure: total_events_count {type: sum sql: ${events_count} ;;}

  # measure: sum_total_new_users_count {type:sum sql:${total_new_users_count};;}

  #demo ratio between fields from different explores.
  measure: items_per_event {
    type: number
    sql: ${order_items_data.total_order_items_count}/nullif(${events_data.total_events_count},0) ;;
    value_format_name: decimal_2
    # Note: Not currently in Scope/Focus of this demo, but we expect to develop support for special drill-paths in links or html
    # link: {url:"/explore/events"}
    # html: [custom presentation logic for rendering looker query results, custom drill links, etc] ;;
  }

  dimension: count_distinct_users_hll {hidden:yes} # For clarity and troubleshooting for develoers, recommend defining dimensions for raw columns in blended source table, even those that are helper columns or should only be used as measures (which we'll define separately).  Should hide and should have naming conventions for such cases

  measure: total_count_distinct_users_hll {
    type: number
    sql: hll_count.merge(${count_distinct_users_hll}) ;;
  }
}

###
# Final End user facting explore(s)

explore: blended_data {
  sql_table_name: /*test*/ ;;
  join: events_data {
    # sql:;;relationship:one_to_one
    sql:full outer join (select 'events' as source,* from ${events_data.SQL_TABLE_NAME}) as events_data on false;;relationship:one_to_one
  }
  join: order_items_data {
    # sql:;;relationship:one_to_one
    sql:full outer join (select 'order_items' as source,* from ${order_items_data.SQL_TABLE_NAME}) as order_items_data on false;;relationship:one_to_one
  }
}

view: blended_data_suggestions {
  derived_table: {
    explore_source: blended_data {
      column: status {field:blended_data.status}
      #bring in measure to force source tables to be brought in
      column: total_events_count {field: events_data.total_events_count}
      column: total_order_items_count {field: order_items_data.total_order_items_count}
    }
  }
  dimension: status {}
}
explore: blended_data_suggestions {

}
