view: field_picker_dynamism_test {
  derived_table: {sql:select 1;;}
  dimension: a {
    view_label: "1{{field_picker_dynamism_test.always_filter_tester._is_filtered}}"
    sql: '1' ;;
  }
  dimension: ua {
    view_label: "1{{_user_attributes['id']}}"
    sql: '1' ;;
  }
  dimension: view_info {
    view_label: "1{{_view._name}}"
    sql: '1' ;;
  }
  dimension: always_filter_tester {
    sql: '1' ;;
  }
}
explore: field_picker_dynamism_test {
  always_filter: {
    filters: [field_picker_dynamism_test.always_filter_tester: "1"]
  }
}
