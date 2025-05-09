include: "//thelook_ecommerce_autogen_files/auto_gen_views/events.view.lkml"
view: +events {}
explore: events {}

view: field_list {
  derived_table: {
    sql:
      {% assign pasted_all_fields =
        '
        "events.count",
        "events.id",
        "events.user_id",
        "events.sequence_number",
        "events.session_id",
        "events.created_at_date",
        "events.created_at_day_of_month",
        "events.created_at_day_of_week",
        "events.created_at_day_of_week_index",
        "events.created_at_day_of_year",
        "events.created_at_hour",
        "events.created_at_hour_of_day",
        "events.created_at_minute",
        "events.created_at_month",
        "events.created_at_month_num",
        "events.created_at_month_name",
        "events.created_at_quarter",
        "events.created_at_quarter_of_year",
        "events.created_at_raw",
        "events.created_at_time",
        "events.created_at_time_of_day",
        "events.created_at_week",
        "events.created_at_week_of_year",
        "events.created_at_year",
        "events.ip_address",
        "events.city",
        "events.state",
        "events.postal_code",
        "events.browser",
        "events.traffic_source",
        "events.uri",
        "events.event_type"
        '
        %};;
  }
}
view: remaining_logic {
  extends: [field_list]
  derived_table: {
    sql:
    ${EXTENDED}
    select

      {% assign stripped_all_fields = pasted_all_fields | strip_newlines  %}
      {% assign all_fields_results = stripped_all_fields |replace: '"','' | split:','%}
      '{% for field in all_fields_results %}{{field}}:{{ _filters[field] | sql_quote | replace: "'","\'" |append: ';' }}{%endfor%}' as all_fields_with_filters_string
      ;;#
  }
}

view: capture_filter_settings__events {
  derived_table: {
    sql:
    select
    {% assign pasted_all_fields =
'
"events.count",
"events.id",
"events.user_id",
"events.sequence_number",
"events.session_id",
"events.created_at_date",
"events.created_at_day_of_month",
"events.created_at_day_of_week",
"events.created_at_day_of_week_index",
"events.created_at_day_of_year",
"events.created_at_hour",
"events.created_at_hour_of_day",
"events.created_at_minute",
"events.created_at_month",
"events.created_at_month_num",
"events.created_at_month_name",
"events.created_at_quarter",
"events.created_at_quarter_of_year",
"events.created_at_raw",
"events.created_at_time",
"events.created_at_time_of_day",
"events.created_at_week",
"events.created_at_week_of_year",
"events.created_at_year",
"events.ip_address",
"events.city",
"events.state",
"events.postal_code",
"events.browser",
"events.traffic_source",
"events.uri",
"events.event_type"
'
%}

       {% assign stripped_all_fields = pasted_all_fields | strip_newlines  %}
       {% assign all_fields_results = stripped_all_fields |replace: '"','' | split:','%}
       '{% for field in all_fields_results %}{{field}}:{{ _filters[field] | sql_quote | replace: "'","\'" |append: ';' }}{%endfor%}' as all_fields_with_filters_string
       ;;#
   }
   dimension: all_fields_with_filters_string {}
}
