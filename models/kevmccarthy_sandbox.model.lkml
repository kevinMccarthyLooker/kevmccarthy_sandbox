
include: "//thelook_ecommerce_autogen_files/basic_model_params"

# include: "//thelook_ecommerce_autogen_files/basic_explores/events.explore.lkml"
# explore: +events {}

include: "//thelook_ecommerce_autogen_files/basic_explores/order_items.explore.lkml"

view: +products {
  dimension: brand {
    label:"tbrandlableadjusted"
    hidden: yes
  }
}
# explore: +order_items {label:"tlabel adjust"}

datagroup: datagroup_24_hours {
  interval_trigger: "24 hours"
}


view: a_pdt {

  derived_table: {
    sql: select 2 as id union all select 101 as id

    ;;
    persist_for: "24 hours"
  }
  dimension: id {type:number}
}
explore: a_pdt {}


include: "/**/bq_information_schema_columns.view"
explore: bq_information_schema_columns {}

include: "/stable_table_name_pdt.view.lkml"
#add persistance here only
view: +stable_table_name_pdt {
  derived_table: {
    publish_as_db_view: yes
    datagroup_trigger: datagroup_24_hours
  }

}
explore: stable_table_name_pdt {}

include: "/GMack_VZ_Liquid_Filtration_question.view.lkml"
explore: gmack_vz_liquid_filtration_question {

}


include: "/eLyons_label_html_question.lkml"


view: order_items_for_Chiaramonte_20250117{
  extends: [order_items]
  measure: avg_sale_price {
    type: average
    sql: ${sale_price} ;;
  }
  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
  }
}
explore: order_items_for_Chiaramonte_20250117 {}


view: test_row_limit_enforcement {
  derived_table: {
    sql:  select 1 as id, 'blue' as color union all

          select 2 , 'blue' union all
          select 3 , 'blue' union all
          select 4 , 'red' union all
          select 5 , 'red' union all
          select 6 , 'red' union all
          select 7 , 'red'
    ;;
  }
  parameter: test_param {

    default_value: "no_restriction"
    allowed_value: {value:"force_25_rows"}
  }
  dimension: id {}
  dimension: color {}
}

explore: test_row_limit_enforcement {
  # sql_always_having: 1=1 ;;
  sql_always_having: 1=1
  {% if test_row_limit_enforcement.test_param._parameter_value == "'force_25_rows'" %}qualify row_number() over() <= 1
  {% endif %}
   ;;
}

include: "/test.dashboard.lookml"


#debargis_transpose_question_20250205:
view: measure_names_transposed {
  dimension: measure_names_transposed {sql:${TABLE};;}
  measure: transposed_mesuare{
    required_fields: [measure_names_transposed]
    type: number
    description: "WARNING: It is expected to use this measure with measure_names_transposed dimension
    , and other 'regular' measures should not be included, as they will be shown repeated for each value among the transposed measures"
    sql:
case
  when measure_names_transposed = 'Order Item Count' then ${order_items.count}
  when measure_names_transposed = 'Total Sale Price' then ${order_items.total_sale_price}
else null end
    ;;

  }

}
explore: order_items_with_transpose_measure {
  from: order_items
  view_name: order_items
  join: measure_names_transposed {
    relationship: one_to_many
    sql:
join unnest(
  ['Order Item Count',
    'Total Sale Price']
) as measure_names_transposed ;;
  }
}


include: "/**/iowa_liquor_stores_sales__main.lkml"


##### SHetty question 3/13 https://yaqs.corp.google.com/gbo/q/7523600727592140800?ved=0CAAQ0qAKahcKEwjguI2-jYaMAxUAAAAAHQAAAAAQJw
view: hide_row_test {
    derived_table: {
      sql:
          SELECT 'Postpaid Phone Gross Adds'  as device_tier, 'Atlantic North'  as Market, 20 as Amount
UNION ALL SELECT 'Postpaid Phone Gross Adds'  as device_tier, 'Pacific       '  as Market, 30 as Amount
UNION ALL SELECT 'Postpaid Phone Gross Adds'  as device_tier, 'Headquarters  '  as Market, 10 as Amount
UNION ALL SELECT 'Tablet Gross Adds        '  as device_tier, 'Atlantic North'  as Market, 30 as Amount
UNION ALL SELECT 'Tablet Gross Adds        '  as device_tier, 'Pacific       '  as Market, 40 as Amount
UNION ALL SELECT 'Tablet Gross Adds        '  as device_tier, 'Headquarters  '  as Market, 60 as Amount
;;
    }

    dimension: device_tier {
      type: string
      sql: ${TABLE}.device_tier ;;
    }

    dimension: Market {
      type: string
      sql: ${TABLE}.Market ;;
    }

    measure: Sales_Amount {
      type: sum
      sql: ${TABLE}.Amount ;;
    }

  }
explore: hide_row_test {}

###
# This was a test 3/17/25 based on Tomoya Mizuno's  question
# learned that this simple override of access_filter does not allow developer to go around it - ths new access filter on the same field just gets added as additional criteria.

# explore: order_items_with_access_filter {
#   from: order_items
#   view_name: order_items
#   access_filter: {
#     field: order_items.user_id
#     user_attribute: id
#   }
# }


# explore: +order_items_with_access_filter {
#   access_filter: {
#     field: order_items.user_id
#     user_attribute: test__id_for_access_filter
#   }
# }

# Was trying to determin explore url from info in ROW (+ drill). Made progress towards checking every field's.. if there's also a filter on that field in explore settings, but realized measure filters are not captured in either drill down link or row.
view: order_items_drill_experiments {
  extends: [order_items]
  measure: row_results_in_html_measure {
    sql: max('placeholder') ;;
    html:
    {% assign result_columns_array = row | remove: '{' | remove: '}' |  split:', ' %}
    {% for column in result_columns_array %}
      {{column}}<br>
    {% endfor %}
    ;;
  }
  measure: drill {
    type: count
    drill_fields: [order_items.*]
  }
  measure: drill_link_text {
    type: count
    #&f[products.category]=Accessories&f[products.department]=Men&f[products.name]=B%25&query_timezone
    html:
    drill link: {{drill._link}}<br>
--list of filters based on drills<br>
    {% assign drill_field_filter_fields = drill._link | split: '&amp;query_timezone' | first | split: '&amp;f'  %}
{% comment %} remove first element{% endcomment %}
    {% assign filter_fields_array_num_elements = drill_field_filter_fields | size | minus: 1 %}
    {% for i in (1..filter_fields_array_num_elements) %}
      {{drill_field_filter_fields[i]}}<br>
    {%endfor%}
    --
    <br>

    {% assign field_array_string = 'products.name;products.category'%}
    {% assign field_array = field_array_string | split: ';'%}
    {% for field in field_array %}
      {{field}}:{{_filters[field]}}<br>
    {% endfor %}
    ;;
    # {% assign field_to_check = 'products.name' %}
    # filters:{{_filters[field_to_check]}}
  }
}
explore: order_items_drill_experiments {extends:[order_items]
  from:order_items_drill_experiments
  view_name: order_items
}

include: "/contribution_analysis_idea/modelling_generic_results.lkml"

# view: chained_ndt_reuse_20250421 {
#   derived_table: {sql: select 1 as id;;}
#   dimension: id {}
# }
# explore: chained_ndt_reuse_20250421 {}

# view: chained_ndt_reuse_20250421_2 {
#   derived_table: {
#     explore_source: chained_ndt_reuse_20250421 {
#       column: id2 {field:chained_ndt_reuse_20250421.id}
#     }
#   }
#   dimension: id2 {}
# }

# view: chained_ndt_reuse_20250421_3 {
#   derived_table: {
#     sql:
#     select id, id2 from {{chained_ndt_reuse_20250421_2._view._name}} left join ${chained_ndt_reuse_20250421.SQL_TABLE_NAME} chained_ndt_reuse_20250421 on ${chained_ndt_reuse_20250421.id}=${chained_ndt_reuse_20250421_2.id}
#     ;;
#   }
#   dimension: id {}
#   dimension: id2 {}
# }
# explore: chained_ndt_reuse_20250421_3 {}


# include: "/capture_current_query_filters.lkml"
# view: test_capture_filters_base {
#   extends: [order_items]

# }
# view: capture_filter_settings__for_test_capture_explore {
#   extends:[capture_filter_settings__template]
#   derived_table: {
#     sql:
#     {% assign x = '1' %}
#     ${EXTENDED} ;;
#   }
#   }
# explore: test_capture_filters_base {
#   # extends: [capture_filter_settings__template_explore_for_extension]
#   join: capture_filter_settings__for_test_capture_explore {relationship: many_to_one type: cross}
# }
include: "/events_explore_with_capture_filters.lkml"
explore: +events {
  join: capture_filter_settings__events {
    relationship: many_to_one
    type: cross
  }
}


include:"/**/ismail_tigrek_formatting_20250429.lkml"
explore: ismail_tigrek_formatting_20250429_order_items {}


include: "/pop_extends_update_test_20250512.lkml"
explore: events_with_pop_base {}
explore: events_with_pop_extension__current {}


view: +order_items {
  dimension: test_2025 {}

}




explore: +order_items {
  join: order_items_field_list {sql:;; relationship:one_to_one}
}

view: order_items_field_list {
  dimension: all_fields_pasted {
    sql:
{% if order_items.view_label._is_selected %} order_items.view_label{% else %} -- order_items.view_label is not selected {% endif %}
{% if order_items.primary_key._is_selected %} order_items.primary_key{% else %} -- order_items.primary_key is not selected {% endif %}
{% if order_items.count._is_selected %} order_items.count{% else %} -- order_items.count is not selected {% endif %}
{% if order_items.id._is_selected %} order_items.id{% else %} -- order_items.id is not selected {% endif %}
{% if order_items.order_id._is_selected %} order_items.order_id{% else %} -- order_items.order_id is not selected {% endif %}
{% if order_items.user_id._is_selected %} order_items.user_id{% else %} -- order_items.user_id is not selected {% endif %}
{% if order_items.product_id._is_selected %} order_items.product_id{% else %} -- order_items.product_id is not selected {% endif %}
{% if order_items.inventory_item_id._is_selected %} order_items.inventory_item_id{% else %} -- order_items.inventory_item_id is not selected {% endif %}
{% if order_items.status._is_selected %} order_items.status{% else %} -- order_items.status is not selected {% endif %}
{% if order_items.created_at_date._is_selected %} order_items.created_at_date{% else %} -- order_items.created_at_date is not selected {% endif %}
{% if order_items.created_at_day_of_month._is_selected %} order_items.created_at_day_of_month{% else %} -- order_items.created_at_day_of_month is not selected {% endif %}
{% if order_items.created_at_day_of_week._is_selected %} order_items.created_at_day_of_week{% else %} -- order_items.created_at_day_of_week is not selected {% endif %}
{% if order_items.created_at_day_of_week_index._is_selected %} order_items.created_at_day_of_week_index{% else %} -- order_items.created_at_day_of_week_index is not selected {% endif %}
{% if order_items.created_at_day_of_year._is_selected %} order_items.created_at_day_of_year{% else %} -- order_items.created_at_day_of_year is not selected {% endif %}
{% if order_items.created_at_hour._is_selected %} order_items.created_at_hour{% else %} -- order_items.created_at_hour is not selected {% endif %}
{% if order_items.created_at_hour_of_day._is_selected %} order_items.created_at_hour_of_day{% else %} -- order_items.created_at_hour_of_day is not selected {% endif %}
{% if order_items.created_at_minute._is_selected %} order_items.created_at_minute{% else %} -- order_items.created_at_minute is not selected {% endif %}
{% if order_items.created_at_month._is_selected %} order_items.created_at_month{% else %} -- order_items.created_at_month is not selected {% endif %}
{% if order_items.created_at_month_num._is_selected %} order_items.created_at_month_num{% else %} -- order_items.created_at_month_num is not selected {% endif %}
{% if order_items.created_at_month_name._is_selected %} order_items.created_at_month_name{% else %} -- order_items.created_at_month_name is not selected {% endif %}
{% if order_items.created_at_quarter._is_selected %} order_items.created_at_quarter{% else %} -- order_items.created_at_quarter is not selected {% endif %}
{% if order_items.created_at_quarter_of_year._is_selected %} order_items.created_at_quarter_of_year{% else %} -- order_items.created_at_quarter_of_year is not selected {% endif %}
{% if order_items.created_at_raw._is_selected %} order_items.created_at_raw{% else %} -- order_items.created_at_raw is not selected {% endif %}
{% if order_items.created_at_time._is_selected %} order_items.created_at_time{% else %} -- order_items.created_at_time is not selected {% endif %}
{% if order_items.created_at_time_of_day._is_selected %} order_items.created_at_time_of_day{% else %} -- order_items.created_at_time_of_day is not selected {% endif %}
{% if order_items.created_at_week._is_selected %} order_items.created_at_week{% else %} -- order_items.created_at_week is not selected {% endif %}
{% if order_items.created_at_week_of_year._is_selected %} order_items.created_at_week_of_year{% else %} -- order_items.created_at_week_of_year is not selected {% endif %}
{% if order_items.created_at_year._is_selected %} order_items.created_at_year{% else %} -- order_items.created_at_year is not selected {% endif %}
{% if order_items.shipped_at_date._is_selected %} order_items.shipped_at_date{% else %} -- order_items.shipped_at_date is not selected {% endif %}
{% if order_items.shipped_at_day_of_month._is_selected %} order_items.shipped_at_day_of_month{% else %} -- order_items.shipped_at_day_of_month is not selected {% endif %}
{% if order_items.shipped_at_day_of_week._is_selected %} order_items.shipped_at_day_of_week{% else %} -- order_items.shipped_at_day_of_week is not selected {% endif %}
{% if order_items.shipped_at_day_of_week_index._is_selected %} order_items.shipped_at_day_of_week_index{% else %} -- order_items.shipped_at_day_of_week_index is not selected {% endif %}
{% if order_items.shipped_at_day_of_year._is_selected %} order_items.shipped_at_day_of_year{% else %} -- order_items.shipped_at_day_of_year is not selected {% endif %}
{% if order_items.shipped_at_hour._is_selected %} order_items.shipped_at_hour{% else %} -- order_items.shipped_at_hour is not selected {% endif %}
{% if order_items.shipped_at_hour_of_day._is_selected %} order_items.shipped_at_hour_of_day{% else %} -- order_items.shipped_at_hour_of_day is not selected {% endif %}
{% if order_items.shipped_at_minute._is_selected %} order_items.shipped_at_minute{% else %} -- order_items.shipped_at_minute is not selected {% endif %}
{% if order_items.shipped_at_month._is_selected %} order_items.shipped_at_month{% else %} -- order_items.shipped_at_month is not selected {% endif %}
{% if order_items.shipped_at_month_num._is_selected %} order_items.shipped_at_month_num{% else %} -- order_items.shipped_at_month_num is not selected {% endif %}
{% if order_items.shipped_at_month_name._is_selected %} order_items.shipped_at_month_name{% else %} -- order_items.shipped_at_month_name is not selected {% endif %}
{% if order_items.shipped_at_quarter._is_selected %} order_items.shipped_at_quarter{% else %} -- order_items.shipped_at_quarter is not selected {% endif %}
{% if order_items.shipped_at_quarter_of_year._is_selected %} order_items.shipped_at_quarter_of_year{% else %} -- order_items.shipped_at_quarter_of_year is not selected {% endif %}
{% if order_items.shipped_at_raw._is_selected %} order_items.shipped_at_raw{% else %} -- order_items.shipped_at_raw is not selected {% endif %}
{% if order_items.shipped_at_time._is_selected %} order_items.shipped_at_time{% else %} -- order_items.shipped_at_time is not selected {% endif %}
{% if order_items.shipped_at_time_of_day._is_selected %} order_items.shipped_at_time_of_day{% else %} -- order_items.shipped_at_time_of_day is not selected {% endif %}
{% if order_items.shipped_at_week._is_selected %} order_items.shipped_at_week{% else %} -- order_items.shipped_at_week is not selected {% endif %}
{% if order_items.shipped_at_week_of_year._is_selected %} order_items.shipped_at_week_of_year{% else %} -- order_items.shipped_at_week_of_year is not selected {% endif %}
{% if order_items.shipped_at_year._is_selected %} order_items.shipped_at_year{% else %} -- order_items.shipped_at_year is not selected {% endif %}
{% if order_items.delivered_at_date._is_selected %} order_items.delivered_at_date{% else %} -- order_items.delivered_at_date is not selected {% endif %}
{% if order_items.delivered_at_day_of_month._is_selected %} order_items.delivered_at_day_of_month{% else %} -- order_items.delivered_at_day_of_month is not selected {% endif %}
{% if order_items.delivered_at_day_of_week._is_selected %} order_items.delivered_at_day_of_week{% else %} -- order_items.delivered_at_day_of_week is not selected {% endif %}
{% if order_items.delivered_at_day_of_week_index._is_selected %} order_items.delivered_at_day_of_week_index{% else %} -- order_items.delivered_at_day_of_week_index is not selected {% endif %}
{% if order_items.delivered_at_day_of_year._is_selected %} order_items.delivered_at_day_of_year{% else %} -- order_items.delivered_at_day_of_year is not selected {% endif %}
{% if order_items.delivered_at_hour._is_selected %} order_items.delivered_at_hour{% else %} -- order_items.delivered_at_hour is not selected {% endif %}
{% if order_items.delivered_at_hour_of_day._is_selected %} order_items.delivered_at_hour_of_day{% else %} -- order_items.delivered_at_hour_of_day is not selected {% endif %}
{% if order_items.delivered_at_minute._is_selected %} order_items.delivered_at_minute{% else %} -- order_items.delivered_at_minute is not selected {% endif %}
{% if order_items.delivered_at_month._is_selected %} order_items.delivered_at_month{% else %} -- order_items.delivered_at_month is not selected {% endif %}
{% if order_items.delivered_at_month_num._is_selected %} order_items.delivered_at_month_num{% else %} -- order_items.delivered_at_month_num is not selected {% endif %}
{% if order_items.delivered_at_month_name._is_selected %} order_items.delivered_at_month_name{% else %} -- order_items.delivered_at_month_name is not selected {% endif %}
{% if order_items.delivered_at_quarter._is_selected %} order_items.delivered_at_quarter{% else %} -- order_items.delivered_at_quarter is not selected {% endif %}
{% if order_items.delivered_at_quarter_of_year._is_selected %} order_items.delivered_at_quarter_of_year{% else %} -- order_items.delivered_at_quarter_of_year is not selected {% endif %}
{% if order_items.delivered_at_raw._is_selected %} order_items.delivered_at_raw{% else %} -- order_items.delivered_at_raw is not selected {% endif %}
{% if order_items.delivered_at_time._is_selected %} order_items.delivered_at_time{% else %} -- order_items.delivered_at_time is not selected {% endif %}
{% if order_items.delivered_at_time_of_day._is_selected %} order_items.delivered_at_time_of_day{% else %} -- order_items.delivered_at_time_of_day is not selected {% endif %}
{% if order_items.delivered_at_week._is_selected %} order_items.delivered_at_week{% else %} -- order_items.delivered_at_week is not selected {% endif %}
{% if order_items.delivered_at_week_of_year._is_selected %} order_items.delivered_at_week_of_year{% else %} -- order_items.delivered_at_week_of_year is not selected {% endif %}
{% if order_items.delivered_at_year._is_selected %} order_items.delivered_at_year{% else %} -- order_items.delivered_at_year is not selected {% endif %}
{% if order_items.returned_at_date._is_selected %} order_items.returned_at_date{% else %} -- order_items.returned_at_date is not selected {% endif %}
{% if order_items.returned_at_day_of_month._is_selected %} order_items.returned_at_day_of_month{% else %} -- order_items.returned_at_day_of_month is not selected {% endif %}
{% if order_items.returned_at_day_of_week._is_selected %} order_items.returned_at_day_of_week{% else %} -- order_items.returned_at_day_of_week is not selected {% endif %}
{% if order_items.returned_at_day_of_week_index._is_selected %} order_items.returned_at_day_of_week_index{% else %} -- order_items.returned_at_day_of_week_index is not selected {% endif %}
{% if order_items.returned_at_day_of_year._is_selected %} order_items.returned_at_day_of_year{% else %} -- order_items.returned_at_day_of_year is not selected {% endif %}
{% if order_items.returned_at_hour._is_selected %} order_items.returned_at_hour{% else %} -- order_items.returned_at_hour is not selected {% endif %}
{% if order_items.returned_at_hour_of_day._is_selected %} order_items.returned_at_hour_of_day{% else %} -- order_items.returned_at_hour_of_day is not selected {% endif %}
{% if order_items.returned_at_minute._is_selected %} order_items.returned_at_minute{% else %} -- order_items.returned_at_minute is not selected {% endif %}
{% if order_items.returned_at_month._is_selected %} order_items.returned_at_month{% else %} -- order_items.returned_at_month is not selected {% endif %}
{% if order_items.returned_at_month_num._is_selected %} order_items.returned_at_month_num{% else %} -- order_items.returned_at_month_num is not selected {% endif %}
{% if order_items.returned_at_month_name._is_selected %} order_items.returned_at_month_name{% else %} -- order_items.returned_at_month_name is not selected {% endif %}
{% if order_items.returned_at_quarter._is_selected %} order_items.returned_at_quarter{% else %} -- order_items.returned_at_quarter is not selected {% endif %}
{% if order_items.returned_at_quarter_of_year._is_selected %} order_items.returned_at_quarter_of_year{% else %} -- order_items.returned_at_quarter_of_year is not selected {% endif %}
{% if order_items.returned_at_raw._is_selected %} order_items.returned_at_raw{% else %} -- order_items.returned_at_raw is not selected {% endif %}
{% if order_items.returned_at_time._is_selected %} order_items.returned_at_time{% else %} -- order_items.returned_at_time is not selected {% endif %}
{% if order_items.returned_at_time_of_day._is_selected %} order_items.returned_at_time_of_day{% else %} -- order_items.returned_at_time_of_day is not selected {% endif %}
{% if order_items.returned_at_week._is_selected %} order_items.returned_at_week{% else %} -- order_items.returned_at_week is not selected {% endif %}
{% if order_items.returned_at_week_of_year._is_selected %} order_items.returned_at_week_of_year{% else %} -- order_items.returned_at_week_of_year is not selected {% endif %}
{% if order_items.returned_at_year._is_selected %} order_items.returned_at_year{% else %} -- order_items.returned_at_year is not selected {% endif %}
{% if order_items.sale_price._is_selected %} order_items.sale_price{% else %} -- order_items.sale_price is not selected {% endif %}
{% if order_items.total_sale_price._is_selected %} order_items.total_sale_price{% else %} -- order_items.total_sale_price is not selected {% endif %}
{% if order_items.test_2025._is_selected %} order_items.test_2025{% else %} -- order_items.test_2025 is not selected {% endif %}
{% if orders.view_label._is_selected %} orders.view_label{% else %} -- orders.view_label is not selected {% endif %}
{% if orders.primary_key._is_selected %} orders.primary_key{% else %} -- orders.primary_key is not selected {% endif %}
{% if orders.count._is_selected %} orders.count{% else %} -- orders.count is not selected {% endif %}
{% if orders.order_id._is_selected %} orders.order_id{% else %} -- orders.order_id is not selected {% endif %}
{% if orders.user_id._is_selected %} orders.user_id{% else %} -- orders.user_id is not selected {% endif %}
{% if orders.status._is_selected %} orders.status{% else %} -- orders.status is not selected {% endif %}
{% if orders.gender._is_selected %} orders.gender{% else %} -- orders.gender is not selected {% endif %}
{% if orders.created_at_date._is_selected %} orders.created_at_date{% else %} -- orders.created_at_date is not selected {% endif %}
{% if orders.created_at_day_of_month._is_selected %} orders.created_at_day_of_month{% else %} -- orders.created_at_day_of_month is not selected {% endif %}
{% if orders.created_at_day_of_week._is_selected %} orders.created_at_day_of_week{% else %} -- orders.created_at_day_of_week is not selected {% endif %}
{% if orders.created_at_day_of_week_index._is_selected %} orders.created_at_day_of_week_index{% else %} -- orders.created_at_day_of_week_index is not selected {% endif %}
{% if orders.created_at_day_of_year._is_selected %} orders.created_at_day_of_year{% else %} -- orders.created_at_day_of_year is not selected {% endif %}
{% if orders.created_at_hour._is_selected %} orders.created_at_hour{% else %} -- orders.created_at_hour is not selected {% endif %}
{% if orders.created_at_hour_of_day._is_selected %} orders.created_at_hour_of_day{% else %} -- orders.created_at_hour_of_day is not selected {% endif %}
{% if orders.created_at_minute._is_selected %} orders.created_at_minute{% else %} -- orders.created_at_minute is not selected {% endif %}
{% if orders.created_at_month._is_selected %} orders.created_at_month{% else %} -- orders.created_at_month is not selected {% endif %}
{% if orders.created_at_month_num._is_selected %} orders.created_at_month_num{% else %} -- orders.created_at_month_num is not selected {% endif %}
{% if orders.created_at_month_name._is_selected %} orders.created_at_month_name{% else %} -- orders.created_at_month_name is not selected {% endif %}
{% if orders.created_at_quarter._is_selected %} orders.created_at_quarter{% else %} -- orders.created_at_quarter is not selected {% endif %}
{% if orders.created_at_quarter_of_year._is_selected %} orders.created_at_quarter_of_year{% else %} -- orders.created_at_quarter_of_year is not selected {% endif %}
{% if orders.created_at_raw._is_selected %} orders.created_at_raw{% else %} -- orders.created_at_raw is not selected {% endif %}
{% if orders.created_at_time._is_selected %} orders.created_at_time{% else %} -- orders.created_at_time is not selected {% endif %}
{% if orders.created_at_time_of_day._is_selected %} orders.created_at_time_of_day{% else %} -- orders.created_at_time_of_day is not selected {% endif %}
{% if orders.created_at_week._is_selected %} orders.created_at_week{% else %} -- orders.created_at_week is not selected {% endif %}
{% if orders.created_at_week_of_year._is_selected %} orders.created_at_week_of_year{% else %} -- orders.created_at_week_of_year is not selected {% endif %}
{% if orders.created_at_year._is_selected %} orders.created_at_year{% else %} -- orders.created_at_year is not selected {% endif %}
{% if orders.returned_at_date._is_selected %} orders.returned_at_date{% else %} -- orders.returned_at_date is not selected {% endif %}
{% if orders.returned_at_day_of_month._is_selected %} orders.returned_at_day_of_month{% else %} -- orders.returned_at_day_of_month is not selected {% endif %}
{% if orders.returned_at_day_of_week._is_selected %} orders.returned_at_day_of_week{% else %} -- orders.returned_at_day_of_week is not selected {% endif %}
{% if orders.returned_at_day_of_week_index._is_selected %} orders.returned_at_day_of_week_index{% else %} -- orders.returned_at_day_of_week_index is not selected {% endif %}
{% if orders.returned_at_day_of_year._is_selected %} orders.returned_at_day_of_year{% else %} -- orders.returned_at_day_of_year is not selected {% endif %}
{% if orders.returned_at_hour._is_selected %} orders.returned_at_hour{% else %} -- orders.returned_at_hour is not selected {% endif %}
{% if orders.returned_at_hour_of_day._is_selected %} orders.returned_at_hour_of_day{% else %} -- orders.returned_at_hour_of_day is not selected {% endif %}
{% if orders.returned_at_minute._is_selected %} orders.returned_at_minute{% else %} -- orders.returned_at_minute is not selected {% endif %}
{% if orders.returned_at_month._is_selected %} orders.returned_at_month{% else %} -- orders.returned_at_month is not selected {% endif %}
{% if orders.returned_at_month_num._is_selected %} orders.returned_at_month_num{% else %} -- orders.returned_at_month_num is not selected {% endif %}
{% if orders.returned_at_month_name._is_selected %} orders.returned_at_month_name{% else %} -- orders.returned_at_month_name is not selected {% endif %}
{% if orders.returned_at_quarter._is_selected %} orders.returned_at_quarter{% else %} -- orders.returned_at_quarter is not selected {% endif %}
{% if orders.returned_at_quarter_of_year._is_selected %} orders.returned_at_quarter_of_year{% else %} -- orders.returned_at_quarter_of_year is not selected {% endif %}
{% if orders.returned_at_raw._is_selected %} orders.returned_at_raw{% else %} -- orders.returned_at_raw is not selected {% endif %}
{% if orders.returned_at_time._is_selected %} orders.returned_at_time{% else %} -- orders.returned_at_time is not selected {% endif %}
{% if orders.returned_at_time_of_day._is_selected %} orders.returned_at_time_of_day{% else %} -- orders.returned_at_time_of_day is not selected {% endif %}
{% if orders.returned_at_week._is_selected %} orders.returned_at_week{% else %} -- orders.returned_at_week is not selected {% endif %}
{% if orders.returned_at_week_of_year._is_selected %} orders.returned_at_week_of_year{% else %} -- orders.returned_at_week_of_year is not selected {% endif %}
{% if orders.returned_at_year._is_selected %} orders.returned_at_year{% else %} -- orders.returned_at_year is not selected {% endif %}
{% if orders.shipped_at_date._is_selected %} orders.shipped_at_date{% else %} -- orders.shipped_at_date is not selected {% endif %}
{% if orders.shipped_at_day_of_month._is_selected %} orders.shipped_at_day_of_month{% else %} -- orders.shipped_at_day_of_month is not selected {% endif %}
{% if orders.shipped_at_day_of_week._is_selected %} orders.shipped_at_day_of_week{% else %} -- orders.shipped_at_day_of_week is not selected {% endif %}
{% if orders.shipped_at_day_of_week_index._is_selected %} orders.shipped_at_day_of_week_index{% else %} -- orders.shipped_at_day_of_week_index is not selected {% endif %}
{% if orders.shipped_at_day_of_year._is_selected %} orders.shipped_at_day_of_year{% else %} -- orders.shipped_at_day_of_year is not selected {% endif %}
{% if orders.shipped_at_hour._is_selected %} orders.shipped_at_hour{% else %} -- orders.shipped_at_hour is not selected {% endif %}
{% if orders.shipped_at_hour_of_day._is_selected %} orders.shipped_at_hour_of_day{% else %} -- orders.shipped_at_hour_of_day is not selected {% endif %}
{% if orders.shipped_at_minute._is_selected %} orders.shipped_at_minute{% else %} -- orders.shipped_at_minute is not selected {% endif %}
{% if orders.shipped_at_month._is_selected %} orders.shipped_at_month{% else %} -- orders.shipped_at_month is not selected {% endif %}
{% if orders.shipped_at_month_num._is_selected %} orders.shipped_at_month_num{% else %} -- orders.shipped_at_month_num is not selected {% endif %}
{% if orders.shipped_at_month_name._is_selected %} orders.shipped_at_month_name{% else %} -- orders.shipped_at_month_name is not selected {% endif %}
{% if orders.shipped_at_quarter._is_selected %} orders.shipped_at_quarter{% else %} -- orders.shipped_at_quarter is not selected {% endif %}
{% if orders.shipped_at_quarter_of_year._is_selected %} orders.shipped_at_quarter_of_year{% else %} -- orders.shipped_at_quarter_of_year is not selected {% endif %}
{% if orders.shipped_at_raw._is_selected %} orders.shipped_at_raw{% else %} -- orders.shipped_at_raw is not selected {% endif %}
{% if orders.shipped_at_time._is_selected %} orders.shipped_at_time{% else %} -- orders.shipped_at_time is not selected {% endif %}
{% if orders.shipped_at_time_of_day._is_selected %} orders.shipped_at_time_of_day{% else %} -- orders.shipped_at_time_of_day is not selected {% endif %}
{% if orders.shipped_at_week._is_selected %} orders.shipped_at_week{% else %} -- orders.shipped_at_week is not selected {% endif %}
{% if orders.shipped_at_week_of_year._is_selected %} orders.shipped_at_week_of_year{% else %} -- orders.shipped_at_week_of_year is not selected {% endif %}
{% if orders.shipped_at_year._is_selected %} orders.shipped_at_year{% else %} -- orders.shipped_at_year is not selected {% endif %}
{% if orders.delivered_at_date._is_selected %} orders.delivered_at_date{% else %} -- orders.delivered_at_date is not selected {% endif %}
{% if orders.delivered_at_day_of_month._is_selected %} orders.delivered_at_day_of_month{% else %} -- orders.delivered_at_day_of_month is not selected {% endif %}
{% if orders.delivered_at_day_of_week._is_selected %} orders.delivered_at_day_of_week{% else %} -- orders.delivered_at_day_of_week is not selected {% endif %}
{% if orders.delivered_at_day_of_week_index._is_selected %} orders.delivered_at_day_of_week_index{% else %} -- orders.delivered_at_day_of_week_index is not selected {% endif %}
{% if orders.delivered_at_day_of_year._is_selected %} orders.delivered_at_day_of_year{% else %} -- orders.delivered_at_day_of_year is not selected {% endif %}
{% if orders.delivered_at_hour._is_selected %} orders.delivered_at_hour{% else %} -- orders.delivered_at_hour is not selected {% endif %}
{% if orders.delivered_at_hour_of_day._is_selected %} orders.delivered_at_hour_of_day{% else %} -- orders.delivered_at_hour_of_day is not selected {% endif %}
{% if orders.delivered_at_minute._is_selected %} orders.delivered_at_minute{% else %} -- orders.delivered_at_minute is not selected {% endif %}
{% if orders.delivered_at_month._is_selected %} orders.delivered_at_month{% else %} -- orders.delivered_at_month is not selected {% endif %}
{% if orders.delivered_at_month_num._is_selected %} orders.delivered_at_month_num{% else %} -- orders.delivered_at_month_num is not selected {% endif %}
{% if orders.delivered_at_month_name._is_selected %} orders.delivered_at_month_name{% else %} -- orders.delivered_at_month_name is not selected {% endif %}
{% if orders.delivered_at_quarter._is_selected %} orders.delivered_at_quarter{% else %} -- orders.delivered_at_quarter is not selected {% endif %}
{% if orders.delivered_at_quarter_of_year._is_selected %} orders.delivered_at_quarter_of_year{% else %} -- orders.delivered_at_quarter_of_year is not selected {% endif %}
{% if orders.delivered_at_raw._is_selected %} orders.delivered_at_raw{% else %} -- orders.delivered_at_raw is not selected {% endif %}
{% if orders.delivered_at_time._is_selected %} orders.delivered_at_time{% else %} -- orders.delivered_at_time is not selected {% endif %}
{% if orders.delivered_at_time_of_day._is_selected %} orders.delivered_at_time_of_day{% else %} -- orders.delivered_at_time_of_day is not selected {% endif %}
{% if orders.delivered_at_week._is_selected %} orders.delivered_at_week{% else %} -- orders.delivered_at_week is not selected {% endif %}
{% if orders.delivered_at_week_of_year._is_selected %} orders.delivered_at_week_of_year{% else %} -- orders.delivered_at_week_of_year is not selected {% endif %}
{% if orders.delivered_at_year._is_selected %} orders.delivered_at_year{% else %} -- orders.delivered_at_year is not selected {% endif %}
{% if orders.num_of_item._is_selected %} orders.num_of_item{% else %} -- orders.num_of_item is not selected {% endif %}
{% if products.view_label._is_selected %} products.view_label{% else %} -- products.view_label is not selected {% endif %}
{% if products.primary_key._is_selected %} products.primary_key{% else %} -- products.primary_key is not selected {% endif %}
{% if products.count._is_selected %} products.count{% else %} -- products.count is not selected {% endif %}
{% if products.id._is_selected %} products.id{% else %} -- products.id is not selected {% endif %}
{% if products.cost._is_selected %} products.cost{% else %} -- products.cost is not selected {% endif %}
{% if products.category._is_selected %} products.category{% else %} -- products.category is not selected {% endif %}
{% if products.name._is_selected %} products.name{% else %} -- products.name is not selected {% endif %}
{% if products.brand._is_selected %} products.brand{% else %} -- products.brand is not selected {% endif %}
{% if products.retail_price._is_selected %} products.retail_price{% else %} -- products.retail_price is not selected {% endif %}
{% if products.department._is_selected %} products.department{% else %} -- products.department is not selected {% endif %}
{% if products.sku._is_selected %} products.sku{% else %} -- products.sku is not selected {% endif %}
{% if products.distribution_center_id._is_selected %} products.distribution_center_id{% else %} -- products.distribution_center_id is not selected {% endif %}
{% if users.view_label._is_selected %} users.view_label{% else %} -- users.view_label is not selected {% endif %}
{% if users.primary_key._is_selected %} users.primary_key{% else %} -- users.primary_key is not selected {% endif %}
{% if users.count._is_selected %} users.count{% else %} -- users.count is not selected {% endif %}
{% if users.id._is_selected %} users.id{% else %} -- users.id is not selected {% endif %}
{% if users.first_name._is_selected %} users.first_name{% else %} -- users.first_name is not selected {% endif %}
{% if users.last_name._is_selected %} users.last_name{% else %} -- users.last_name is not selected {% endif %}
{% if users.email._is_selected %} users.email{% else %} -- users.email is not selected {% endif %}
{% if users.age._is_selected %} users.age{% else %} -- users.age is not selected {% endif %}
{% if users.gender._is_selected %} users.gender{% else %} -- users.gender is not selected {% endif %}
{% if users.state._is_selected %} users.state{% else %} -- users.state is not selected {% endif %}
{% if users.street_address._is_selected %} users.street_address{% else %} -- users.street_address is not selected {% endif %}
{% if users.postal_code._is_selected %} users.postal_code{% else %} -- users.postal_code is not selected {% endif %}
{% if users.city._is_selected %} users.city{% else %} -- users.city is not selected {% endif %}
{% if users.country._is_selected %} users.country{% else %} -- users.country is not selected {% endif %}
{% if users.latitude._is_selected %} users.latitude{% else %} -- users.latitude is not selected {% endif %}
{% if users.longitude._is_selected %} users.longitude{% else %} -- users.longitude is not selected {% endif %}
{% if users.traffic_source._is_selected %} users.traffic_source{% else %} -- users.traffic_source is not selected {% endif %}
{% if users.created_at_date._is_selected %} users.created_at_date{% else %} -- users.created_at_date is not selected {% endif %}
{% if users.created_at_day_of_month._is_selected %} users.created_at_day_of_month{% else %} -- users.created_at_day_of_month is not selected {% endif %}
{% if users.created_at_day_of_week._is_selected %} users.created_at_day_of_week{% else %} -- users.created_at_day_of_week is not selected {% endif %}
{% if users.created_at_day_of_week_index._is_selected %} users.created_at_day_of_week_index{% else %} -- users.created_at_day_of_week_index is not selected {% endif %}
{% if users.created_at_day_of_year._is_selected %} users.created_at_day_of_year{% else %} -- users.created_at_day_of_year is not selected {% endif %}
{% if users.created_at_hour._is_selected %} users.created_at_hour{% else %} -- users.created_at_hour is not selected {% endif %}
{% if users.created_at_hour_of_day._is_selected %} users.created_at_hour_of_day{% else %} -- users.created_at_hour_of_day is not selected {% endif %}
{% if users.created_at_minute._is_selected %} users.created_at_minute{% else %} -- users.created_at_minute is not selected {% endif %}
{% if users.created_at_month._is_selected %} users.created_at_month{% else %} -- users.created_at_month is not selected {% endif %}
{% if users.created_at_month_num._is_selected %} users.created_at_month_num{% else %} -- users.created_at_month_num is not selected {% endif %}
{% if users.created_at_month_name._is_selected %} users.created_at_month_name{% else %} -- users.created_at_month_name is not selected {% endif %}
{% if users.created_at_quarter._is_selected %} users.created_at_quarter{% else %} -- users.created_at_quarter is not selected {% endif %}
{% if users.created_at_quarter_of_year._is_selected %} users.created_at_quarter_of_year{% else %} -- users.created_at_quarter_of_year is not selected {% endif %}
{% if users.created_at_raw._is_selected %} users.created_at_raw{% else %} -- users.created_at_raw is not selected {% endif %}
{% if users.created_at_time._is_selected %} users.created_at_time{% else %} -- users.created_at_time is not selected {% endif %}
{% if users.created_at_time_of_day._is_selected %} users.created_at_time_of_day{% else %} -- users.created_at_time_of_day is not selected {% endif %}
{% if users.created_at_week._is_selected %} users.created_at_week{% else %} -- users.created_at_week is not selected {% endif %}
{% if users.created_at_week_of_year._is_selected %} users.created_at_week_of_year{% else %} -- users.created_at_week_of_year is not selected {% endif %}
{% if users.created_at_year._is_selected %} users.created_at_year{% else %} -- users.created_at_year is not selected {% endif %}
{% if users.location._is_selected %} users.location{% else %} -- users.location is not selected {% endif %}
{% if users.location_bin_level._is_selected %} users.location_bin_level{% else %} -- users.location_bin_level is not selected {% endif %}
{% if users.location_latitude_min._is_selected %} users.location_latitude_min{% else %} -- users.location_latitude_min is not selected {% endif %}
{% if users.location_latitude_max._is_selected %} users.location_latitude_max{% else %} -- users.location_latitude_max is not selected {% endif %}
{% if users.location_longitude_min._is_selected %} users.location_longitude_min{% else %} -- users.location_longitude_min is not selected {% endif %}
{% if users.location_longitude_max._is_selected %} users.location_longitude_max{% else %} -- users.location_longitude_max is not selected {% endif %}
    ;;
  }

}


include: "/hll_test2.view.lkml"


view: +order_items {
  measure: sales_completed {
    type: sum
    sql: ${sale_price} ;;
    filters: [status: "Complete"]
  }
  measure: complete_sales_dollar_percent {
    type: number
    sql: ${sales_completed}/${sales_completed} ;;
    value_format_name: percent_1
  }
}
























view: order_items_with_special_bucket_of_fields_kasin_20250530 {
  view_label: "Order Items"
  sql_table_name: `bigquery-public-data.thelook_ecommerce.order_items` ;;
  dimension: created_date {
    type: date
    sql: ${TABLE}.created_at ;;
  }
  dimension: status {}
  dimension: sale_price {type:number}
  measure: count {type:count}
  measure: total_sales {
    label: "Total Sales Original"
    # hidden: yes #maybe hide this after re-implemented it in the other view
    type:sum
    sql:${sale_price};;
  }
}

view: special_view_for_targeted_in_query_check {
  #note that view is 'sourceless' (so can't use ${TABLE})
  measure: total_sales {
    view_label: "Order Items" # probably want to curate view labels in these special fields
    type:sum
    sql:${order_items_with_special_bucket_of_fields_kasin_20250530.sale_price};;
  }
}
explore: order_items_with_special_bucket_of_fields_kasin_20250530 {
  #'bare-joining view'.. no actual join happens
  join: special_view_for_targeted_in_query_check {sql: /*this is where the join would go */;; relationship:one_to_one}
  #example use of in_query logic:
  sql_always_where:
  {% if special_view_for_targeted_in_query_check._in_query %}
    ${order_items_with_special_bucket_of_fields_kasin_20250530.created_date}>'2025-01-01'
  {% endif %};;
}


##bare join example problem
view: bare_join_sym_aggs_problem_base {
  derived_table: {sql: select id as base_id from unnest([1,2,3]) as id /*multi-row example base table*/;;}
  dimension: base_id {}
  dimension: pk {
    primary_key:yes
    sql: ${base_id} ;;
  }
  measure: count {#type:count}
    type: sum #use a sum instead.. actually has a sql param i can use, but still 'counting'
    sql: ${placeholder} ;;
  }
  dimension: placeholder {type:number sql:1;;}
}
view: bare_join_sym_aggs_problem_one_to_many {
  derived_table: {sql: select id as base_id,to_many_id as to_many_id from unnest([1,2,3]) as id left join unnest(['a','b','c']) as to_many_id /*multi-row example base table*/;;}
  dimension: base_id {}
  dimension: to_many_id {}
  dimension: pk {
    primary_key: yes
    sql:concat(${base_id},${to_many_id});;
  }
  measure: count {type:count}
}
view: referencing_a_measure_in_a_bare_joined_view_to_cause_a_problem {
  #should be same as bare_join_sym_aggs_problem_base.count, but fails to adhere to sym aggs
  measure: problem {
    type: sum #use a sum instead.. actually has a sql param i can use, but still 'counting'
    sql: ${bare_join_sym_aggs_problem_base.placeholder};;
  }
  dimension: pk {
    primary_key: yes
    sql:concat(${bare_join_sym_aggs_problem_base.pk},${bare_join_sym_aggs_problem_base.pk});;
  }
}

explore: bare_join_sym_aggs_problem_base {
  join: bare_join_sym_aggs_problem_one_to_many {
    relationship: one_to_many
    sql_on: ${bare_join_sym_aggs_problem_one_to_many.base_id}=${bare_join_sym_aggs_problem_base.base_id} ;;
  }
  join: referencing_a_measure_in_a_bare_joined_view_to_cause_a_problem {relationship: one_to_one sql: ;;}
}



view: order_items_for_test_override_bind_all {
  view_label: "Order Items"
  sql_table_name: `bigquery-public-data.thelook_ecommerce.order_items` ;;
  dimension: created_date {type: date sql: ${TABLE}.created_at ;;}
  dimension: status {}
  dimension: sale_price {type:number}
  dimension: is_dt_if_selected_toggle {sql:'placeholder';;}
  parameter: date_filter_parameter {type:date}
  measure: total_sales {
    type:sum
    sql:${sale_price};;
  }
  measure: count {type:count}

  parameter: measure_selector_for_user_query {}
  parameter: measure_selector_for_dt {}
  measure: dynamic_measure {type: number
    sql:
{% if measure_selector_for_dt._parameter_value == "'sales'" %}${total_sales}
{%else%}
  {% if measure_selector_for_user_query._parameter_value == "'sales'" %}${total_sales}{%else%}${count}{%endif%}
{%endif%}
  ;;
  }
}
view: order_items__dt_for_test_override_bind_all {
  derived_table: {
    explore_source: order_items_for_test_override_bind_all {
      column: status {}
      column: is_dt_if_selected_toggle {}
      column: total_sales {}
      column: dynamic_measure {}
      bind_all_filters: yes

      filters: [
        order_items_for_test_override_bind_all.measure_selector_for_dt: "sales",
        order_items_for_test_override_bind_all.created_date: ""
      ]
    }
  }
  dimension: status {}
  dimension: total_sales_for_status {sql:${TABLE}.total_sales;;}
  dimension: dynamic_measure {sql:${TABLE}.dynamic_measure;;}
}
# view: order_items__dt_for_test_override_bind_all_sql {
#   extends: [order_items__dt_for_test_override_bind_all]
#   sql_table_name: ${EXTENDED}  ;;
#   # derived_table: {
#   #   # sql: ${EXTENDED} ;;
#   # }
#   dimension: test {}
# }
explore: order_items_for_test_override_bind_all {
  join: order_items__dt_for_test_override_bind_all {
    relationship: many_to_one
    sql_on: ${order_items_for_test_override_bind_all.status}= ${order_items__dt_for_test_override_bind_all.status} ;;
  }
  # join: order_items__dt_for_test_override_bind_all_sql {relationship:one_to_one sql:;;}
  sql_always_where:
  --is_dt_if_selected_toggle._is_selected:{{is_dt_if_selected_toggle._is_selected}}
  {% if is_dt_if_selected_toggle._is_selected %}{%else%}{%condition date_filter_parameter %}${created_date}{% endcondition %}{% endif %} ;;
}
