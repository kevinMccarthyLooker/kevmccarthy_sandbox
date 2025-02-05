# view: elyons20250204_filters_question {
#   extends: [order_items]
#   dimension: number_days_in_created_at_date_filter {}
#   parameter: date_filter_param {
#     type: date
#   }
#   dimension: date_start {
#     type: number
#     sql: date_diff({% date_end created_at_date %},{% date_start created_at_date %},DAY) ;;
#   }
#   measure: total_value {
#     type: sum
#     sql: ${sale_price} ;;

#     # html:<div class="vis"><div class="vis-single-value" data-toggle="tooltip" data-placement="top" title="My Custom Tooltip :)" >{{rendered_value}}</div></div>;;
#     html:<div class="vis-single-value" data-toggle="tooltip" data-placement="top" title="My Custom Tooltip :)" >{{rendered_value}}</div>;;
#     # html:<div data-toggle="tooltip" data-placement="top" title="My Custom Tooltip :)" >{{rendered_value}}</div>;;

#     value_format: "#,##0.0,,\"m\""
#   }
# }

# explore: elyons20250204_filters_question {}
