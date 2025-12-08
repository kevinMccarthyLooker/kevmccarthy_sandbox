view: test_sql_preamble_capture_and_edit_query_view {
  derived_table: {sql:select * from thekitchentable.kevmccarthy_sandbox_dataset.order_items_partitioned;;}
  dimension: id {type:number}
  dimension: user_id {}
  measure: total {type:sum sql:${id};;}
}

explore: sql_preamble_capture_and_edit_query{
# DECLARE sql string;
# SET sql = concat('select count(*) from thelook_with_orders_km.');
# EXECUTE IMMEDIATE format("""
# %s
# """,sql
# );
# EXECUTE IMMEDIATE """select user_id from `thekitchentable.kevmccarthy_sandbox_dataset.order_items` group by all qualify row_number() over(order by sum(sale_price) desc) = 1 ' INTO y;

# --inquery grain check {% if test_sql_preamble_capture_and_edit_query_view.user_id._in_query %}1{% else %}{{test_sql_preamble_capture_and_edit_query_view.user_id._in_query}}{% endif %}
  sql_preamble:

DECLARE y INT64;
DECLARE capture_sql STRING;
SET capture_sql = """
  ;;
  from: test_sql_preamble_capture_and_edit_query_view
  view_name: test_sql_preamble_capture_and_edit_query_view
  # sql_always_where:
  # ${test_sql_preamble_capture_and_edit_query_view.user_id}=;;
sql_always_where:
1=1
"""
;;
# --inquery grain check {% if test_sql_preamble_capture_and_edit_query_view.user_id._in_query %}1{% else %}{{test_sql_preamble_capture_and_edit_query_view.user_id._in_query}}{% endif %}

  sql_always_having:
  1=1
  ) AS t3
ORDER BY
    test_sql_preamble_capture_and_edit_query_view_user_id DESC
LIMIT 500
""";
EXECUTE IMMEDIATE (capture_sql).replace('(test_sql_preamble_capture_and_edit_query_view.id) =','(test_sql_preamble_capture_and_edit_query_view.id) >');
return;
select null from (select null

  ;;
}
