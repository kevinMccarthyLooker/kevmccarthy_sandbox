connection: "sample_bigquery_connection"
include: "//thelook_ecommerce_autogen_files/auto_gen_views/order_items.view.lkml"

view: +order_items {

  measure: drill {
    type: count
    drill_fields: [id,created_at_date]
  }
  measure: special_drill {
    type: count
    html:
    {% assign encoded_row_info = row  | replace: '"', '' %}
    {% assign quoted_encoded_row_info = '%22' | append: encoded_row_info  | append: '%22' %}
    {% assign value_to_inject = 'f[order_items.catch_url_data]=' | append: quoted_encoded_row_info | append: '&query_timezone' %}
    <a href="{{drill._link | replace: 'query_timezone', value_to_inject}}">special test link </a> ;;
  }



  parameter: catch_url_data {
    type: string
  }
}
explore: order_items {}

# '&f[order_items.catch_url_data]=wfew+wef%5E+%5E+&query_timezone'

view: capture_filter_settings__order_items_explore {
  derived_table: {
    sql:
    select
{% assign pasted_all_fields =
'
"order_items.count",
"order_items.id",
"order_items.order_id",
"order_items.user_id",
"order_items.product_id",
"order_items.inventory_item_id",
"order_items.status",
"order_items.created_at_date",
"order_items.created_at_day_of_month",
"order_items.created_at_day_of_week",
"order_items.created_at_day_of_week_index",
"order_items.created_at_day_of_year",
"order_items.created_at_hour",
"order_items.created_at_hour_of_day",
"order_items.created_at_minute",
"order_items.created_at_month",
"order_items.created_at_month_num",
"order_items.created_at_month_name",
"order_items.created_at_quarter",
"order_items.created_at_quarter_of_year",
"order_items.created_at_raw",
"order_items.created_at_time",
"order_items.created_at_time_of_day",
"order_items.created_at_week",
"order_items.created_at_week_of_year",
"order_items.created_at_year",
"order_items.shipped_at_date",
"order_items.shipped_at_day_of_month",
"order_items.shipped_at_day_of_week",
"order_items.shipped_at_day_of_week_index",
"order_items.shipped_at_day_of_year",
"order_items.shipped_at_hour",
"order_items.shipped_at_hour_of_day",
"order_items.shipped_at_minute",
"order_items.shipped_at_month",
"order_items.shipped_at_month_num",
"order_items.shipped_at_month_name",
"order_items.shipped_at_quarter",
"order_items.shipped_at_quarter_of_year",
"order_items.shipped_at_raw",
"order_items.shipped_at_time",
"order_items.shipped_at_time_of_day",
"order_items.shipped_at_week",
"order_items.shipped_at_week_of_year",
"order_items.shipped_at_year",
"order_items.delivered_at_date",
"order_items.delivered_at_day_of_month",
"order_items.delivered_at_day_of_week",
"order_items.delivered_at_day_of_week_index",
"order_items.delivered_at_day_of_year",
"order_items.delivered_at_hour",
"order_items.delivered_at_hour_of_day",
"order_items.delivered_at_minute",
"order_items.delivered_at_month",
"order_items.delivered_at_month_num",
"order_items.delivered_at_month_name",
"order_items.delivered_at_quarter",
"order_items.delivered_at_quarter_of_year",
"order_items.delivered_at_raw",
"order_items.delivered_at_time",
"order_items.delivered_at_time_of_day",
"order_items.delivered_at_week",
"order_items.delivered_at_week_of_year",
"order_items.delivered_at_year",
"order_items.returned_at_date",
"order_items.returned_at_day_of_month",
"order_items.returned_at_day_of_week",
"order_items.returned_at_day_of_week_index",
"order_items.returned_at_day_of_year",
"order_items.returned_at_hour",
"order_items.returned_at_hour_of_day",
"order_items.returned_at_minute",
"order_items.returned_at_month",
"order_items.returned_at_month_num",
"order_items.returned_at_month_name",
"order_items.returned_at_quarter",
"order_items.returned_at_quarter_of_year",
"order_items.returned_at_raw",
"order_items.returned_at_time",
"order_items.returned_at_time_of_day",
"order_items.returned_at_week",
"order_items.returned_at_week_of_year",
"order_items.returned_at_year",
"order_items.sale_price",
"order_items.drill",
"order_items.special_drill",
"order_items.catch_url_data"
'
%}

{% assign stripped_all_fields = pasted_all_fields | strip_newlines  %}
{% assign all_fields_results = stripped_all_fields |replace: '"','' | split:','%}
'{% for field in all_fields_results %}{{field}}:{{ _filters[field] | sql_quote | replace: "'","\'" |append: ';' }}{%endfor%}' as all_fields_with_filters_string
;;#
  }
  dimension: all_fields_with_filters_string {
  }
}

explore: +order_items {
  join: capture_filter_settings__order_items_explore {
    # sql:;;
    type: cross
    relationship:one_to_one
  }
}
