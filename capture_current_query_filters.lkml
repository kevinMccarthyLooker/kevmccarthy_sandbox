view: capture_filter_settings__template {
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
  dimension: all_fields_with_filters_string {}
}

explore: capture_filter_settings__template_explore_for_extension  {
  extension: required
  join: capture_filter_settings__template {
    relationship: many_to_one
    type: cross
  }
}
