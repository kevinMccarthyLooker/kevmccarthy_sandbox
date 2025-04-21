
include: "//thelook_ecommerce_autogen_files/basic_model_params"

include: "//thelook_ecommerce_autogen_files/basic_explores/events.explore.lkml"
# explore: +events {}

include: "//thelook_ecommerce_autogen_files/basic_explores/order_items.explore.lkml"

view: +products {
  dimension: brand {
    label:"tbrandlableadjusted"
    hidden: yes
  }
}
explore: +order_items {label:"tlabel adjust"}

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
