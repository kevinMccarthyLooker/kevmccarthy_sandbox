

#We will use this to create a liquid array variable 'all_fields_results' with the pasted field names
view: all_fields_array {
derived_table: {sql:
{%- assign pasted_all_fields =
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
'
%}

{%- assign stripped_all_fields = pasted_all_fields | strip_newlines  -%}
{%- assign all_fields_results = stripped_all_fields |replace: '"','' | split:','%}
    ;;
  }

}

view: capture_filter_settings__template {
  extends: [all_fields_array]
  derived_table: {
    sql:${EXTENDED}
select
'{%- for field in all_fields_results -%}{{field}}:{{ _filters[field] | sql_quote | replace: "'","" |append: ';' }}{%endfor%}' as all_fields_with_filters_string
      ;;#
  }

}
view: capture_is_selected_settings__template {
  extends: [all_fields_array]
  derived_table: {
    sql:${EXTENDED}
    all_fields_results:{{all_fields_results}}
    {%- for field in all_fields_results -%}
    {%- assign looker_field = order_items.status -%}
    {{looker_field._in_query}}

    {%endfor%}

            ;;#

    }
  # sql_table_name:
  # t
  # {{- _filters['order_items.count']-}}
  # {{- _filters['order_items.id']-}}
  # {{- _filters['order_items.order_id']-}}
  # {{- _filters['order_items.user_id']-}}
  # {{- _filters['order_items.product_id']-}}
  # {{- _filters['order_items.inventory_item_id']-}}
  # {{- _filters['order_items.status']-}}
  # {{- _filters['order_items.created_at_date']-}}
  # {{- _filters['order_items.created_at_day_of_month']-}}
  # {{- _filters['order_items.created_at_day_of_week']-}}
  # {{- _filters['order_items.created_at_day_of_week_index']-}}
  # {{- _filters['order_items.created_at_day_of_year']-}}
  # {{- _filters['order_items.created_at_hour']-}}
  # {{- _filters['order_items.created_at_hour_of_day']-}}
  # {{- _filters['order_items.created_at_minute']-}}
  # {{- _filters['order_items.created_at_month']-}}
  # {{- _filters['order_items.created_at_month_num']-}}
  # {{- _filters['order_items.created_at_month_name']-}}
  # {{- _filters['order_items.created_at_quarter']-}}
  # {{- _filters['order_items.created_at_quarter_of_year']-}}
  # {{- _filters['order_items.created_at_raw']-}}
  # {{- _filters['order_items.created_at_time']-}}
  # {{- _filters['order_items.created_at_time_of_day']-}}
  # {{- _filters['order_items.created_at_week']-}}
  # {{- _filters['order_items.created_at_week_of_year']-}}
  # {{- _filters['order_items.created_at_year']-}}
  # {{- _filters['order_items.shipped_at_date']-}}
  # {{- _filters['order_items.shipped_at_day_of_month']-}}
  # {{- _filters['order_items.shipped_at_day_of_week']-}}
  # {{- _filters['order_items.shipped_at_day_of_week_index']-}}
  # {{- _filters['order_items.shipped_at_day_of_year']-}}
  # {{- _filters['order_items.shipped_at_hour']-}}
  # {{- _filters['order_items.shipped_at_hour_of_day']-}}
  # {{- _filters['order_items.shipped_at_minute']-}}
  # {{- _filters['order_items.shipped_at_month']-}}
  # {{- _filters['order_items.shipped_at_month_num']-}}
  # {{- _filters['order_items.shipped_at_month_name']-}}
  # {{- _filters['order_items.shipped_at_quarter']-}}
  # {{- _filters['order_items.shipped_at_quarter_of_year']-}}
  # {{- _filters['order_items.shipped_at_raw']-}}
  # {{- _filters['order_items.shipped_at_time']-}}
  # {{- _filters['order_items.shipped_at_time_of_day']-}}
  # {{- _filters['order_items.shipped_at_week']-}}
  # {{- _filters['order_items.shipped_at_week_of_year']-}}
  # {{- _filters['order_items.shipped_at_year']-}}
  # {{- _filters['order_items.delivered_at_date']-}}
  # {{- _filters['order_items.delivered_at_day_of_month']-}}
  # {{- _filters['order_items.delivered_at_day_of_week']-}}
  # {{- _filters['order_items.delivered_at_day_of_week_index']-}}
  # {{- _filters['order_items.delivered_at_day_of_year']-}}
  # {{- _filters['order_items.delivered_at_hour']-}}
  # {{- _filters['order_items.delivered_at_hour_of_day']-}}
  # {{- _filters['order_items.delivered_at_minute']-}}
  # {{- _filters['order_items.delivered_at_month']-}}
  # {{- _filters['order_items.delivered_at_month_num']-}}
  # {{- _filters['order_items.delivered_at_month_name']-}}
  # {{- _filters['order_items.delivered_at_quarter']-}}
  # {{- _filters['order_items.delivered_at_quarter_of_year']-}}
  # {{- _filters['order_items.delivered_at_raw']-}}
  # {{- _filters['order_items.delivered_at_time']-}}
  # {{- _filters['order_items.delivered_at_time_of_day']-}}
  # {{- _filters['order_items.delivered_at_week']-}}
  # {{- _filters['order_items.delivered_at_week_of_year']-}}
  # {{- _filters['order_items.delivered_at_year']-}}
  # {{- _filters['order_items.returned_at_date']-}}
  # {{- _filters['order_items.returned_at_day_of_month']-}}
  # {{- _filters['order_items.returned_at_day_of_week']-}}
  # {{- _filters['order_items.returned_at_day_of_week_index']-}}
  # {{- _filters['order_items.returned_at_day_of_year']-}}
  # {{- _filters['order_items.returned_at_hour']-}}
  # {{- _filters['order_items.returned_at_hour_of_day']-}}
  # {{- _filters['order_items.returned_at_minute']-}}
  # {{- _filters['order_items.returned_at_month']-}}
  # {{- _filters['order_items.returned_at_month_num']-}}
  # {{- _filters['order_items.returned_at_month_name']-}}
  # {{- _filters['order_items.returned_at_quarter']-}}
  # {{- _filters['order_items.returned_at_quarter_of_year']-}}
  # {{- _filters['order_items.returned_at_raw']-}}
  # {{- _filters['order_items.returned_at_time']-}}
  # {{- _filters['order_items.returned_at_time_of_day']-}}
  # {{- _filters['order_items.returned_at_week']-}}
  # {{- _filters['order_items.returned_at_week_of_year']-}}
  # {{- _filters['order_items.returned_at_year']-}}
  # {{- _filters['order_items.sale_price']-}}
  # ;;
    dimension: all_fields_is_filtered {

    }
    dimension: all_fields_is_selected {
      sql:
{%- if order_items.count._in_query -%}{{order_items.count._name}},{%- endif -%}
{%- if order_items.id._in_query -%}{{order_items.id._name}},{%- endif -%}
{%- if order_items.order_id._in_query -%}{{order_items.order_id._name}},{%- endif -%}
{%- if order_items.user_id._in_query -%}{{order_items.user_id._name}},{%- endif -%}
{%- if order_items.product_id._in_query -%}{{order_items.product_id._name}},{%- endif -%}
{%- if order_items.inventory_item_id._in_query -%}{{order_items.inventory_item_id._name}},{%- endif -%}
{%- if order_items.status._in_query -%}{{order_items.status._name}},{%- endif -%}
{%- if order_items.created_at_date._in_query -%}{{order_items.created_at_date._name}},{%- endif -%}
{%- if order_items.created_at_day_of_month._in_query -%}{{order_items.created_at_day_of_month._name}},{%- endif -%}
{%- if order_items.created_at_day_of_week._in_query -%}{{order_items.created_at_day_of_week._name}},{%- endif -%}
{%- if order_items.created_at_day_of_week_index._in_query -%}{{order_items.created_at_day_of_week_index._name}},{%- endif -%}
{%- if order_items.created_at_day_of_year._in_query -%}{{order_items.created_at_day_of_year._name}},{%- endif -%}
{%- if order_items.created_at_hour._in_query -%}{{order_items.created_at_hour._name}},{%- endif -%}
{%- if order_items.created_at_hour_of_day._in_query -%}{{order_items.created_at_hour_of_day._name}},{%- endif -%}
{%- if order_items.created_at_minute._in_query -%}{{order_items.created_at_minute._name}},{%- endif -%}
{%- if order_items.created_at_month._in_query -%}{{order_items.created_at_month._name}},{%- endif -%}
{%- if order_items.created_at_month_num._in_query -%}{{order_items.created_at_month_num._name}},{%- endif -%}
{%- if order_items.created_at_month_name._in_query -%}{{order_items.created_at_month_name._name}},{%- endif -%}
{%- if order_items.created_at_quarter._in_query -%}{{order_items.created_at_quarter._name}},{%- endif -%}
{%- if order_items.created_at_quarter_of_year._in_query -%}{{order_items.created_at_quarter_of_year._name}},{%- endif -%}
{%- if order_items.created_at_raw._in_query -%}{{order_items.created_at_raw._name}},{%- endif -%}
{%- if order_items.created_at_time._in_query -%}{{order_items.created_at_time._name}},{%- endif -%}
{%- if order_items.created_at_time_of_day._in_query -%}{{order_items.created_at_time_of_day._name}},{%- endif -%}
{%- if order_items.created_at_week._in_query -%}{{order_items.created_at_week._name}},{%- endif -%}
{%- if order_items.created_at_week_of_year._in_query -%}{{order_items.created_at_week_of_year._name}},{%- endif -%}
{%- if order_items.created_at_year._in_query -%}{{order_items.created_at_year._name}},{%- endif -%}
{%- if order_items.shipped_at_date._in_query -%}{{order_items.shipped_at_date._name}},{%- endif -%}
{%- if order_items.shipped_at_day_of_month._in_query -%}{{order_items.shipped_at_day_of_month._name}},{%- endif -%}
{%- if order_items.shipped_at_day_of_week._in_query -%}{{order_items.shipped_at_day_of_week._name}},{%- endif -%}
{%- if order_items.shipped_at_day_of_week_index._in_query -%}{{order_items.shipped_at_day_of_week_index._name}},{%- endif -%}
{%- if order_items.shipped_at_day_of_year._in_query -%}{{order_items.shipped_at_day_of_year._name}},{%- endif -%}
{%- if order_items.shipped_at_hour._in_query -%}{{order_items.shipped_at_hour._name}},{%- endif -%}
{%- if order_items.shipped_at_hour_of_day._in_query -%}{{order_items.shipped_at_hour_of_day._name}},{%- endif -%}
{%- if order_items.shipped_at_minute._in_query -%}{{order_items.shipped_at_minute._name}},{%- endif -%}
{%- if order_items.shipped_at_month._in_query -%}{{order_items.shipped_at_month._name}},{%- endif -%}
{%- if order_items.shipped_at_month_num._in_query -%}{{order_items.shipped_at_month_num._name}},{%- endif -%}
{%- if order_items.shipped_at_month_name._in_query -%}{{order_items.shipped_at_month_name._name}},{%- endif -%}
{%- if order_items.shipped_at_quarter._in_query -%}{{order_items.shipped_at_quarter._name}},{%- endif -%}
{%- if order_items.shipped_at_quarter_of_year._in_query -%}{{order_items.shipped_at_quarter_of_year._name}},{%- endif -%}
{%- if order_items.shipped_at_raw._in_query -%}{{order_items.shipped_at_raw._name}},{%- endif -%}
{%- if order_items.shipped_at_time._in_query -%}{{order_items.shipped_at_time._name}},{%- endif -%}
{%- if order_items.shipped_at_time_of_day._in_query -%}{{order_items.shipped_at_time_of_day._name}},{%- endif -%}
{%- if order_items.shipped_at_week._in_query -%}{{order_items.shipped_at_week._name}},{%- endif -%}
{%- if order_items.shipped_at_week_of_year._in_query -%}{{order_items.shipped_at_week_of_year._name}},{%- endif -%}
{%- if order_items.shipped_at_year._in_query -%}{{order_items.shipped_at_year._name}},{%- endif -%}
{%- if order_items.delivered_at_date._in_query -%}{{order_items.delivered_at_date._name}},{%- endif -%}
{%- if order_items.delivered_at_day_of_month._in_query -%}{{order_items.delivered_at_day_of_month._name}},{%- endif -%}
{%- if order_items.delivered_at_day_of_week._in_query -%}{{order_items.delivered_at_day_of_week._name}},{%- endif -%}
{%- if order_items.delivered_at_day_of_week_index._in_query -%}{{order_items.delivered_at_day_of_week_index._name}},{%- endif -%}
{%- if order_items.delivered_at_day_of_year._in_query -%}{{order_items.delivered_at_day_of_year._name}},{%- endif -%}
{%- if order_items.delivered_at_hour._in_query -%}{{order_items.delivered_at_hour._name}},{%- endif -%}
{%- if order_items.delivered_at_hour_of_day._in_query -%}{{order_items.delivered_at_hour_of_day._name}},{%- endif -%}
{%- if order_items.delivered_at_minute._in_query -%}{{order_items.delivered_at_minute._name}},{%- endif -%}
{%- if order_items.delivered_at_month._in_query -%}{{order_items.delivered_at_month._name}},{%- endif -%}
{%- if order_items.delivered_at_month_num._in_query -%}{{order_items.delivered_at_month_num._name}},{%- endif -%}
{%- if order_items.delivered_at_month_name._in_query -%}{{order_items.delivered_at_month_name._name}},{%- endif -%}
{%- if order_items.delivered_at_quarter._in_query -%}{{order_items.delivered_at_quarter._name}},{%- endif -%}
{%- if order_items.delivered_at_quarter_of_year._in_query -%}{{order_items.delivered_at_quarter_of_year._name}},{%- endif -%}
{%- if order_items.delivered_at_raw._in_query -%}{{order_items.delivered_at_raw._name}},{%- endif -%}
{%- if order_items.delivered_at_time._in_query -%}{{order_items.delivered_at_time._name}},{%- endif -%}
{%- if order_items.delivered_at_time_of_day._in_query -%}{{order_items.delivered_at_time_of_day._name}},{%- endif -%}
{%- if order_items.delivered_at_week._in_query -%}{{order_items.delivered_at_week._name}},{%- endif -%}
{%- if order_items.delivered_at_week_of_year._in_query -%}{{order_items.delivered_at_week_of_year._name}},{%- endif -%}
{%- if order_items.delivered_at_year._in_query -%}{{order_items.delivered_at_year._name}},{%- endif -%}
{%- if order_items.returned_at_date._in_query -%}{{order_items.returned_at_date._name}},{%- endif -%}
{%- if order_items.returned_at_day_of_month._in_query -%}{{order_items.returned_at_day_of_month._name}},{%- endif -%}
{%- if order_items.returned_at_day_of_week._in_query -%}{{order_items.returned_at_day_of_week._name}},{%- endif -%}
{%- if order_items.returned_at_day_of_week_index._in_query -%}{{order_items.returned_at_day_of_week_index._name}},{%- endif -%}
{%- if order_items.returned_at_day_of_year._in_query -%}{{order_items.returned_at_day_of_year._name}},{%- endif -%}
{%- if order_items.returned_at_hour._in_query -%}{{order_items.returned_at_hour._name}},{%- endif -%}
{%- if order_items.returned_at_hour_of_day._in_query -%}{{order_items.returned_at_hour_of_day._name}},{%- endif -%}
{%- if order_items.returned_at_minute._in_query -%}{{order_items.returned_at_minute._name}},{%- endif -%}
{%- if order_items.returned_at_month._in_query -%}{{order_items.returned_at_month._name}},{%- endif -%}
{%- if order_items.returned_at_month_num._in_query -%}{{order_items.returned_at_month_num._name}},{%- endif -%}
{%- if order_items.returned_at_month_name._in_query -%}{{order_items.returned_at_month_name._name}},{%- endif -%}
{%- if order_items.returned_at_quarter._in_query -%}{{order_items.returned_at_quarter._name}},{%- endif -%}
{%- if order_items.returned_at_quarter_of_year._in_query -%}{{order_items.returned_at_quarter_of_year._name}},{%- endif -%}
{%- if order_items.returned_at_raw._in_query -%}{{order_items.returned_at_raw._name}},{%- endif -%}
{%- if order_items.returned_at_time._in_query -%}{{order_items.returned_at_time._name}},{%- endif -%}
{%- if order_items.returned_at_time_of_day._in_query -%}{{order_items.returned_at_time_of_day._name}},{%- endif -%}
{%- if order_items.returned_at_week._in_query -%}{{order_items.returned_at_week._name}},{%- endif -%}
{%- if order_items.returned_at_week_of_year._in_query -%}{{order_items.returned_at_week_of_year._name}},{%- endif -%}
{%- if order_items.returned_at_year._in_query -%}{{order_items.returned_at_year._name}},{%- endif -%}
{%- if order_items.sale_price._in_query -%}{{order_items.sale_price._name}},{%- endif -%}

{%- if users.gender._in_query -%}{{users.gender._name}},{%- endif -%}


      ;;
    }

    dimension: is_selected_values {
sql:
      {%- assign pasted_all_fields =
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
        "x.sale_price",
        '
        -%}
      {%- assign stripped_all_fields = pasted_all_fields | strip_newlines  -%}
      {%- assign all_fields_results = stripped_all_fields |replace: '"','' | split:','%}

   {%- for field in all_fields_results -%}
        field:{{field}}
        {%- assign looker_field = 'field' -%}
        looker_field1:{{looker_field}}
        looker_field:{{looker_field._name}}
        in_query:{{looker_field._in_query}}

        {%-  assign view_name = field | split: '.' | first  -%}
      view_name:{{view_name}}
        {%-  assign field_name = field | split: '.' | last  -%}
      field_name:{{field_name}}

{%- assign the_view = order_items -%}
{%- assign the_field = the_view[field_name] -%}

      a_field_in_query:{{the_field._in_query}}
      a_field_in_query:{{the_field._sql}}
      a_field_in_query:{{the_field._label}}
      a_field_in_query:{{the_field._description}}
      a_field_in_query:{{the_field._filters}}

{%- assign s = order_items.returned_at_year._view -%}
      s:{{s}}
        --
    {%endfor%}
;;
# {%-  assign a_view = order_items  -%}
    }
}

explore: capture_filter_settings__template_explore_for_extension  {
  extension: required
  join: capture_filter_settings__template {
    relationship: many_to_one
    type: cross
  }
}






#######################################
# include: "/capture_current_query_filters.lkml"
include: "//thelook_ecommerce_autogen_files/basic_explores/order_items.explore.lkml"
explore: test_capture_filters_base {

  # view_name: order_items
  extends: [capture_filter_settings__template_explore_for_extension]
  # join: capture_filter_settings__for_test_capture_explore {relationship: many_to_one type: cross}
  join: order_items {
    sql:
    full outer join order_items on false
    ;; relationship:one_to_one
  }
  join: users {
    sql_on:${users.id}=${order_items.user_id};;
    relationship: many_to_one
  }
  join: capture_is_selected_settings__template {relationship:one_to_one sql:;;}

# sql_always_having:
# 1=1
# )

# )

# select * from (
# select * from another_view
# union all
# select * from another_view

#   ;;

sql_always_having:
1=1
)
)
,forecast as (
SELECT
  -- * --(status,forecast_timestamp,forecast_value,confidence_level,prediction_interval_lower_bound,prediction_interval_upper_bound, ai_forecast_status)
  date(forecast_timestamp) as order_items_created_at_date,
  forecast_value as order_items_total_sale_price
  --order_items_status,
  --'forecast' as forecast
    {% assign selected_fields = capture_is_selected_settings__template.all_fields_is_selected._sql | split:','%}
    {% for field in selected_fields %}
      {% assign renamed_field = field | replace: '.','_' %}
      --field:{{renamed_field}}
      {% if renamed_field == 'order_items_created_at_date' %}--order_items_created_at_date
      {% elsif renamed_field == 'order_items_total_sale_price' %}--order_items_total_sale_price
      {% elsif renamed_field == 'test_capture_filters_base_forecast' %}--test_capture_filters_base_forecast
      {% else %},{{renamed_field}}
      {% endif %}
    {% endfor %}

  FROM
  AI.FORECAST(
  -- TABLE `kevmccarthy.thelook_with_orders_km.forecast_input_dataset`,
  -- TABLE dataset,
  --{{capture_is_selected_settings__template.all_fields_is_selected._sql}}


  TABLE another_view,
  timestamp_col => 'order_items_created_at_date',-- timestamp_col => 'created_month',
  data_col => 'order_items_total_sale_price', -- data_col => 'total_sales',
  model => 'TimesFM 2.0',

  /*
  id_cols => [
  'order_items_status'
  -- -- ,'department'

  ],
  */
  id_cols => [
  {% assign selected_fields = capture_is_selected_settings__template.all_fields_is_selected._sql | split:','%}
  {% for field in selected_fields %}
  {% assign renamed_field = field | replace: '.','_' %}
  --field:{{renamed_field}}
  {% if renamed_field == 'order_items_created_at_date' %}--order_items_created_at_date
  {% elsif renamed_field == 'order_items_total_sale_price' %}--order_items_total_sale_price
  {% elsif renamed_field == 'test_capture_filters_base_forecast' %}--test_capture_filters_base_forecast
  {% else %}'{{renamed_field}}'
  {% endif %}
  {% endfor %}
  ],
  horizon => 50,
  confidence_level => .75
  )
  )

  select * from (
  select * from another_view
  union all
  select another_view.* replace(
  forecast.order_items_created_at_date as order_items_created_at_date,
  forecast.order_items_total_sale_price as order_items_total_sale_price,
  'forecast' as test_capture_filters_base_forecast

  --forecast.order_items_status as order_items_status,
  {% assign selected_fields = capture_is_selected_settings__template.all_fields_is_selected._sql | split:','%}
  {% for field in selected_fields %}
  {% assign renamed_field = field | replace: '.','_' %}
  --field:{{renamed_field}}
  {% if renamed_field == 'order_items_created_at_date' %}--order_items_created_at_date
  {% elsif renamed_field == 'order_items_total_sale_price' %}--order_items_total_sale_price
  {% elsif renamed_field == 'test_capture_filters_base_forecast' %}--test_capture_filters_base_forecast
  {% else %},forecast.{{renamed_field}} as {{renamed_field}}
  {% endif %}
  {% endfor %}
  ) from (select * from another_view where 1=0) as another_view
  full outer join
  (
  select *
  -- date(forecast_timestamp),status,forecast_value
  from forecast
  ) as forecast on false

  ;;
always_join: [another_view]
join: another_view {
  # sql: another_view_s_join ;;
  sql: ;;
relationship: one_to_one
}
}
view: another_view {
  derived_table: {

    sql:
    /*TABLES INCLUDED*/
    /*${order_items.SQL_TABLE_NAME}*/

      --;;
#;;
    }
  }

  view: test_capture_filters_base {
    derived_table: {

# sql:
# /*TABLES INCLUDED*/
# /*${order_items.SQL_TABLE_NAME}*/

# --;;
# #;;
      sql:
      /*TABLES INCLUDED*/
      /*${order_items.SQL_TABLE_NAME}*/

        select (null);;

    }
    dimension:forecast {
      sql: 'regular' ;;
    }
    measure: forecast_sale_price {
      type: sum
      sql: order_items_total_sale_price ;;
      filters: [forecast: "forecast"]
    }
  }



#this version creates ability to build upon end user quer
#all within the selct clause itself
#(so it works even when there's pivot
#note: relies on adding a helper dimension
# # needs to be alphabetically first in base view so it comes first
# # and also hacks the having clause
  view: test_capture_filters_test2 {
    sql_table_name: (select '1' as id,'regular' as regular, 'zz' as zz) ;;
    dimension: aa {
      sql:
      --inject a wrapper around main query.  this will be preceeded with initial 'select...'
      *
      --example manipulation of result set
      {% if regular._in_query %}
        REPLACE('test' as test_capture_filters_test2_regular)
      {% endif %}
      from (with result_set as
      (
      select
      'placeholder'
      ;;
    }
    measure: aa_required_measure {
      type: string
      # sql: 't223234' ;;
      sql:
      {% if aa._is_selected %}
      't'
      {% else %}
                  --inject a wrapper around main query.  this will be preceeded with initial 'select...'
      *
      -- REPLACE('test' as test_capture_filters_test2_regular)
      from (with result_set as
      (
      select
      't'
      {%endif%}
      ;;
    }
    dimension: required_filter {
      required_fields: [aa,aa_required_measure]
    }
    dimension: regular {}
    dimension: zz {}
    measure: count {type:count
      # required_fields: [aa]
    }
    measure: forecast_count {
      type:count
      required_fields: [aa]
    }

    measure: test_for_having {
      required_fields: [aa,aa_required_measure]
      type: string
      sql: true ;;
#     sql:
# {% if forecast_count._in_query %}
# 1=1))--end having clause
# )--end of injection of wrapper around main query CTE called we named result_set
#   select *,result_set from result_set
# {% else %}true
# {% endif %}
#   ;;
    }
    measure: special_having {
      # type: number
      # sql: 1 ;;
      type: string
      sql: 'KEEP FOR HAVING CLAUSE' ;;
    }
  }

  explore: test_capture_filters_test2 {

    always_filter: {filters:[special_having: "KEEP FOR HAVING CLAUSE"]}
    # always_filter: {filters:[test_capture_filters_test2.count: "1"]}

    sql_always_having:
    1=1)--end having clause
    {% if test_capture_filters_test2.special_having._is_filtered %}
    )/*end original main query */ select *,result_set from result_set
    /*looker will inject ')' for planned end of having clause and then ')' for end of Looker's main query wrapper for having clause*/
    {% else %}
    /*end original main query */ select *,result_set from result_set)
    /*This case represents no user measure filters selected... looker will NOT inject ')' for planned end of having clause as above, but will still inject ')' for end of Looker's main query wrapper for having clause*/
    {% endif %}

      ;;
    # sql_always_having:
    # ${test_capture_filters_test2.test_for_having}/*always having*/
    # ;;
    # sql_always_having:  true;;
  }





