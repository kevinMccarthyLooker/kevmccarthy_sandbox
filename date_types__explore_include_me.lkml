view: dates_query_query {
  # dimension: date_overall_start {sql:'2000-01-01';;}
  # dimension: date_overall_end {sql:'2049-12-31';;}
  derived_table: {
    sql:
    {% assign date_overall_start = '2000-01-01' %}{% assign date_overall_end = '2049-12-31' %}
    with days as (select generated_day,1 as row_count from unnest(generate_date_array('{{- date_overall_start -}}','{{- date_overall_end -}}')) generated_day)
    ,template as           (select 'original template' row_type, generated_day,1 row_count,days,if(1=0,days,null) as d0,if(1=0,days,null) as d1, if(1=0,days,null) as d2 from days)
    ,nullified_template as (select * replace('nullified template' as row_type,null as row_count) from template where 1=0)
    ,template_with_nulls_available_in_full_joined_struct as (select template,nullified_template from template full outer join nullified_template on false)

      select template.days.generated_day as days.generated_day, template.* replace('d0' as row_type, template.days as d0 ) from template_with_nulls_available_in_full_joined_struct
union all
      select date_add(template.generated_day, INTERVAL 1 year) as days.generated_day, template.* replace('d1' as row_type, template.days as d1 , date_add(template.generated_day, INTERVAL 1 year) as generated_day) from template_with_nulls_available_in_full_joined_struct

      --select 'base' row_type, generated_day,1 as row_count,days as date_types, if(1=0,days,null) as quarterly  from days
      --union all select 'quarterly' as row_type, generated_day,1 as row_count, null as date_types, (select as struct days.* replace('quarterly' as row_type)) as quarterly /*replace( (generated_day).qtr() as generated_day)*/ from days
      ;;
    # --date_diff(date('2000-01-01'),generated_day, day) as days_from_2000,
  }
}
view: dates_query_fields {
  dimension: TABLE_REPLACEABLE {sql:dates_query_query;;}
  # extends: [date_types]


  dimension_group: generated_day {
    type: time
    datatype: date
    sql:${TABLE_REPLACEABLE}.generated_day;;
  }
  measure: row_count {type:sum sql:${TABLE_REPLACEABLE}.row_count;;}

  measure: min_date {type:date sql:min(${generated_day_date});;}
#   measure: max_date {type:date sql:max(${generated_day_date});;}
#   measure: min_day_number_of_year {type:number sql:min(${generated_day_day_of_year});;}
#   measure: max_day_number_of_year {type:number sql:max(${generated_day_day_of_year});;}

#   measure: date_range {type:string sql:concat(${min_date},' - ',${max_date});;}
#   measure: day_number_of_year_range {type:string sql:concat(${min_day_number_of_year},' - ',${max_day_number_of_year});;}

}
# dates_query_query,
view:dates_query {
  dimension: TABLE_REPLACEABLE {sql:${dates_query_query.SQL_TABLE_NAME};;}
  extends: [dates_query_fields]
}
view:days {
  dimension: TABLE_REPLACEABLE {sql:days;;}
  extends: [dates_query_fields]
}
view:d0 {
  dimension: TABLE_REPLACEABLE {sql:d0;;}
  extends: [dates_query_fields]
}
view:d1 {
  dimension: TABLE_REPLACEABLE {sql:d1;;}
  extends: [dates_query_fields]
}

explore:  dates_query{
  # from: dates_query_query
  # view_name: dates_query
  sql_table_name: ${dates_query_query.SQL_TABLE_NAME};;
  join: days {sql:;;relationship:one_to_one}
  join: d0 {sql:;;relationship:one_to_one}
  join: d1 {sql:;;relationship:one_to_one}
}


# view: date_types {
#   dimension: special_table_name {sql:(dates_query.date_types);;}

#   dimension: row_type {sql:${special_table_name}.row_type;;}
#   dimension_group: current {
#     view_label: "Ref: Current Date"
#     type: time
#     datatype: date
#     sql:current_date() ;;
#   }
#   dimension_group: current_timestamp {
#     view_label: "Ref: Current Date"
#     type: time
#     datatype: timestamp
#     sql:current_timestamp() ;;
#   }
#   # dimension: capture_filter_on_current_timestamp_in_label {label: "{{_filters['current_timestamp_time']}}"}
#   dimension: capture_filter_on_current_timestamp {
#     view_label: "Ref: Current Date"
#     sql:
# /*:date_start current_timestamp_time:{% date_start current_timestamp_time %}*/
# /*:date_end current_timestamp_time:{% date_end current_timestamp_time %}*/
# /*{% condition current_timestamp_time %}{% endcondition %}*/
#     {% date_start current_timestamp_time %};;
#   }


#     # sql:{{'now' | date: '}} ;;
#   dimension: current_mtd_number {
#     view_label: "Ref: Current Date"
#     type: number
#     sql: extract(day from ${date_types.current_date}) ;;
#   }

#   dimension_group: generated_day {
#     type: time
#     # timeframes: []
#     datatype: date
#     sql:${special_table_name}.generated_day;;
#   }
#   measure: row_count {type:sum sql:case when ${special_table_name}.row_type is not null then 1 else 0 end;;}
#   measure: day_count {type:count_distinct sql:${special_table_name}.generated_day;;}
#   measure: min_date {type:date sql:min(${generated_day_date});;}
#   measure: max_date {type:date sql:max(${generated_day_date});;}
#   measure: min_day_number_of_year {type:number sql:min(${generated_day_day_of_year});;}
#   measure: max_day_number_of_year {type:number sql:max(${generated_day_day_of_year});;}

#   measure: date_range {type:string sql:concat(${min_date},' - ',${max_date});;}
#   measure: day_number_of_year_range {type:string sql:concat(${min_day_number_of_year},' - ',${max_day_number_of_year});;}

# #This is Kev's preferred way of creating a boolean feature toggle.  One Allowed value.  If user adds the param from field picker then it is set and we react to that, otherwise it's empty and we assume it's untouched
#   parameter: allow_dates_in_future {
#     default_value: "Unset" #Defual Applies if the parameter is not set at all
#     allowed_value: {value:"Allow 1 Year"} #Choices in the UI.... Doesn't have to include the default value. The first allow value will be the one set if default value isn't one of the allowed ones
#     allowed_value: {value:"Allow All"} #Choices in the UI.... Doesn't have to include the default value
#     allowed_value: {value:"Do not Allow Future (Default)"} #Choices in the UI.... Doesn't have to include the default value. The first allow value will be the one set if default value isn't one of the allowed ones
#   }
#   parameter: mtd_only {
#     default_value: "Unset" #Defual Applies if the parameter is not set at all
#     allowed_value: {value:"MTD Only"} #Choices in the UI.... Doesn't have to include the default value. The first allow value will be the one set if default value isn't one of the allowed ones
#   }
#   parameter: ytd_only {
#     default_value: "Unset" #Defual Applies if the parameter is not set at all
#     allowed_value: {value:"YTD Only"} #Choices in the UI.... Doesn't have to include the default value. The first allow value will be the one set if default value isn't one of the allowed ones
#   }
# }

# view: quarterly {
#   extends:[date_types]
#   dimension: special_table_name {sql:(dates_query.quarterly);;}
# }

# explore: dates_query {

#   sql_preamble:
#   create temp function mnth(tmstmp ANY TYPE) as (date_trunc(tmstmp,month));
#   create temp function qtr(tmstmp ANY TYPE) as (date_trunc(tmstmp,quarter));
#   ;;
#   join: date_types {sql:;;relationship:one_to_one}
#   join: quarterly {sql:;;relationship:one_to_one}


# #   sql_always_where:
# # /*begin sql always where*/ 1=1
# # --date_types.allow_dates_in_future._is_filtered:{{date_types.allow_dates_in_future._is_filtered}}
# # --date_types.allow_dates_in_future._parameter_value:{{date_types.allow_dates_in_future._parameter_value}}
# # {% if date_types.allow_dates_in_future._parameter_value == "'Allow All'" %}/*allow_dates_in_future set to Allow*/
# # {% elsif date_types.allow_dates_in_future._parameter_value == "'Allow 1 Year'" %}/*allow_dates_in_future set to Allow*/and ${generated_day_date}<date_add(${current_date}, interval 1 year)
# # {% elsif date_types.allow_dates_in_future._parameter_value == 'Unset' %}/*filtering because allow_dates_in_future was not set*/and ${generated_day_date}<${current_date}
# # {% endif %}
# #   ;;

#   sql_always_where:
# /*begin sql always where*/ 1=1
# /*date_types.allow_dates_in_future._is_filtered:{{date_types.allow_dates_in_future._is_filtered}}*/
# {% if date_types.allow_dates_in_future._is_filtered == 'false' %}/*allow_dates_in_future was not set: filtering to current date*/and ${dates_query.generated_day_date}<${date_types.current_date}
# {% else %}
#   /*date_types.allow_dates_in_future._parameter_value:{{date_types.allow_dates_in_future._parameter_value}}*/
#   {% case date_types.allow_dates_in_future._parameter_value %}
#     {% when "'Allow All'"                             %}/*allow_dates_in_future set to Allow All: no filter*/
#     {% when "'Allow 1 Year'"                          %}/*allow_dates_in_future set to Allow 1 Year: no filter*/and ${dates_query.generated_day_date}<date_add(${date_types.current_date}, interval 1 year)
#     {% when "'Do not Allow Future (Default)'"         %}/*Backup of default value... */and ${dates_query.generated_day_date}<${date_types.current_date}
#     {% when "'Unset'"                                 %}/*Backup of default value... */and ${dates_query.generated_day_date}<${date_types.current_date}
#     {% else                                           %}--unexpectedly hit else... check logic
#   {% endcase %}
# {% endif %}

# /*date_types.mtd_only._is_filtered:{{date_types.mtd_only._is_filtered}}*/
# {% if date_types.mtd_only._is_filtered == 'false' %}
# {% else %}
#   /*date_types.allow_dates_in_future._parameter_value:{{date_types.allow_dates_in_future._parameter_value}}*/
#   {% case date_types.mtd_only._parameter_value %}
#     {% when "'MTD Only'" %}
#       and
# (     1=0
#       {%- assign mtd_date_cutoff = 'now' | date: '%e' %}
#       {%- assign overall_begin_year = 2000 %}{% assign overall_end_year   = 2050 %}
#       {%- assign iteration_year = overall_begin_year %}
#       {%- assign iteration_month = 1 %}
#       {%- for iteration in (0..1000) -%}
#         {% if iteration_year >= overall_end_year %}{% break %}{% endif %}
#         or ('{{iteration_year}}-{{iteration_month | prepend: "00" | slice: -2,2 }}-01'<=${dates_query.generated_day_date} and ${dates_query.generated_day_date}<'{{iteration_year}}-{{iteration_month | prepend: "00" | slice: -2,2 }}-{{mtd_date_cutoff}}')
#         {%- assign iteration_month = iteration_month | plus: 1 %}
#         {%- if iteration_month >= 13 %}
#           {%- assign iteration_year = iteration_year | plus: 1 %}
#           {%- assign iteration_month = 1 %}
#         {%- endif %}
#       {%- endfor %}
# )
#     {% when "'Unset'"%}
#     {% else  %}--unexpectedly hit else... check logic against value:{{date_types.mtd_only._parameter_value}}
#   {% endcase %}
# {% endif %}

# /*date_types.ytd_only._is_filtered:{{date_types.ytd_only._is_filtered}}*/
# {% if date_types.ytd_only._is_filtered == 'false' %}
# {% else %}
#   /*date_types.allow_dates_in_future._parameter_value:{{date_types.allow_dates_in_future._parameter_value}}*/
#   {% case date_types.ytd_only._parameter_value %}
#     {% when "'YTD Only'" %}
#       and
# (     1=0
#       {%- assign mtd_date_cutoff = 'now' | date: '%e' %}
#       {%- assign ytd_date_cutoff = 'now' | date: '%m' %}
#       {%- assign overall_begin_year = 2000 %}{% assign overall_end_year   = 2050 %}
#       {%- assign iteration_year = overall_begin_year %}
#       {%- for iteration in (0..1000) -%}
#         {% if iteration_year >= overall_end_year %}{% break %}{% endif %}
#         or ('{{iteration_year}}-01-01'<=${dates_query.generated_day_date} and ${dates_query.generated_day_date}<'{{iteration_year}}-{{ytd_date_cutoff}}-{{mtd_date_cutoff}}')
#         {%- assign iteration_year = iteration_year | plus: 1 %}
#       {%- endfor %}
# )
#     {% when "'Unset'"%}
#     {% else  %}--unexpectedly hit else... check logic against value:{{date_types.mtd_only._parameter_value}}
#   {% endcase %}
# {% endif %}

# ;;
#       # {% assign iteration_overall_date_begin = '2020-01-01' | date %}{% assign iterationoverall_date_end = '2030-01-01' | date %}
#       # {% assign iteration_date = iteration_overall_date_begin  %}
#       # {% assign iteration_date_year = iteration_date | date: '%Y' %}
#         #       {% assign iteration_date_month = iteration_date_month | plus: 1 %}
#         # {% if iteration_date_month >= 13 %}{% assign iteration_date_year = iteration_date_year | plus: 1 %}{% assign iteration_date_month = 1 %}{% endif %}
#         # {% assign iteration_date = iteration_date  %}




# #   {% case handle %}
# #   {% when "cake" %}
# #     This is a cake
# #   {% when "cookie", "biscuit" %}
# #     This is a cookie
# #   {% else %}
# #     This is not a cake nor a cookie
# # {% endcase %}
# }
