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
