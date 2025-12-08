# ---
# - dashboard: data_history_playback
#   title: data history playback
#   layout: newspaper
#   preferred_viewer: dashboards-next
#   description: ''
#   preferred_slug: nOmDQf3CwEOP0UAfHgDE1l
#   elements:
#   - title: data history playback
#     name: data history playback
#     model: kevmccarthy_sandbox
#     explore: order_items
#     type: looker_area
#     fields: [orders.count, orders.created_at_date, orders.status]
#     pivots: [orders.status]
#     filters:
#       orders.created_at_date: ''
#       orders.created_at_week: after 2000/10/01
#       # orders.d2: ''
#     sorts: [orders.status, orders.created_at_date]
#     limit: 500
#     column_limit: 50
#     dynamic_fields:
#     - category: table_calculation
#       expression: if(sum(pivot_row(${orders.count}))>30, sum(pivot_row(${orders.count})),null)
#       label: count highlight
#       value_format:
#       value_format_name:
#       _kind_hint: supermeasure
#       table_calculation: count_highlight
#       _type_hint: number
#     x_axis_gridlines: false
#     y_axis_gridlines: true
#     show_view_names: false
#     show_y_axis_labels: true
#     show_y_axis_ticks: true
#     y_axis_tick_density: default
#     y_axis_tick_density_custom: 5
#     show_x_axis_label: true
#     show_x_axis_ticks: true
#     y_axis_scale_mode: linear
#     x_axis_reversed: false
#     y_axis_reversed: false
#     plot_size_by_field: false
#     trellis: ''
#     stacking: normal
#     limit_displayed_rows: false
#     legend_position: center
#     point_style: none
#     show_value_labels: false
#     label_density: 25
#     x_axis_scale: auto
#     y_axis_combined: true
#     show_null_points: false
#     interpolation: linear
#     show_totals_labels: false
#     show_silhouette: false
#     totals_color: "#808080"
#     x_axis_zoom: true
#     y_axis_zoom: true
#     series_types:
#       count_highlight: scatter
#     reference_lines: [{reference_type: line, range_start: max, range_end: min, margin_top: deviation,
#         margin_value: mean, margin_bottom: deviation, label_position: right, color: "#000000",
#         line_value: '30'}]
#     trend_lines: []
#     ordering: none
#     show_null_labels: false
#     show_row_numbers: true
#     truncate_column_names: false
#     hide_totals: false
#     hide_row_totals: false
#     table_theme: gray
#     enable_conditional_formatting: false
#     conditional_formatting_include_totals: false
#     conditional_formatting_include_nulls: false
#     defaults_version: 1
#     hidden_fields:
#     hidden_pivots: {}
#     listen: {}
#     row: 0
#     col: 0
#     width: 23
#     height: 13
#   - title: '2'
#     name: '2'
#     model: kevmccarthy_sandbox
#     explore: order_items
#     type: looker_area
#     fields: [orders.count, orders.created_at_date, orders.status, orders.count_over_30]
#     pivots: [orders.status]
#     filters:
#       orders.created_at_date: ''
#       orders.created_at_week: after 2000/10/01
#       # orders.d2: ''
#     sorts: [orders.status, orders.created_at_date]
#     limit: 500
#     column_limit: 50
#     row_total: right
#     dynamic_fields:
#     - category: table_calculation
#       expression: if(sum(pivot_row(${orders.count}))>30, sum(pivot_row(${orders.count})),null)
#       label: count highlight
#       value_format:
#       value_format_name:
#       _kind_hint: supermeasure
#       table_calculation: count_highlight
#       _type_hint: number
#       is_disabled: true
#     x_axis_gridlines: false
#     y_axis_gridlines: true
#     show_view_names: false
#     show_y_axis_labels: true
#     show_y_axis_ticks: true
#     y_axis_tick_density: default
#     y_axis_tick_density_custom: 5
#     show_x_axis_label: true
#     show_x_axis_ticks: true
#     y_axis_scale_mode: linear
#     x_axis_reversed: false
#     y_axis_reversed: false
#     plot_size_by_field: false
#     trellis: ''
#     stacking: normal
#     limit_displayed_rows: false
#     legend_position: center
#     point_style: none
#     show_value_labels: false
#     label_density: 25
#     x_axis_scale: auto
#     y_axis_combined: true
#     show_null_points: false
#     interpolation: linear
#     show_totals_labels: false
#     show_silhouette: false
#     totals_color: "#808080"
#     x_axis_zoom: true
#     y_axis_zoom: true
#     series_types:
#       confirmed - orders.count_over_30: scatter
#       Row Total - orders.count_over_30: scatter
#       Row Total - orders.count: line
#     series_colors:
#       Row Total - orders.count: "#12B5CB"
#       Row Total - orders.count_over_30: "#E52592"
#     reference_lines: [{reference_type: line, range_start: max, range_end: min, margin_top: deviation,
#         margin_value: mean, margin_bottom: deviation, label_position: right, color: "#000000",
#         line_value: '30'}]
#     trend_lines: []
#     ordering: none
#     show_null_labels: false
#     show_row_numbers: true
#     truncate_column_names: false
#     hide_totals: false
#     hide_row_totals: false
#     table_theme: gray
#     enable_conditional_formatting: false
#     conditional_formatting_include_totals: false
#     conditional_formatting_include_nulls: false
#     defaults_version: 1
#     hidden_fields:
#     hidden_pivots:
#       "$$$_row_total_$$$":
#         is_entire_pivot_hidden: false
#       cancelled:
#         measure_names:
#         - orders.count_over_30
#       confirmed:
#         measure_names:
#         - orders.count_over_30
#     listen: {}
#     row: 13
#     col: 0
#     width: 8
#     height: 6
#   - title: 2 (Copy)
#     name: 2 (Copy)
#     model: kevmccarthy_sandbox
#     explore: order_items
#     type: looker_timeline
#     fields: [orders.user_id, orders.status, orders.min_date, orders.max_date
#     # , sum_of_order_amount
#     ]
#     filters:
#       orders.created_at_date: ''
#       orders.created_at_week: after 2000/10/01
#     sorts: [orders.status, orders.user_id]
#     limit: 500
#     column_limit: 50
#     dynamic_fields:
#     # - _kind_hint: measure
#     #   _type_hint: number
#     #   based_on: orders.order_amount
#     #   expression: ''
#     #   label: Sum of Order Amount
#     #   measure: sum_of_order_amount
#     #   type: sum
#     # - category: table_calculation
#     #   expression: if(sum(pivot_row(${orders.count}))>30, sum(pivot_row(${orders.count})),null)
#     #   label: count highlight
#     #   value_format:
#     #   value_format_name:
#     #   _kind_hint: supermeasure
#     #   table_calculation: count_highlight
#     #   _type_hint: number
#     #   is_disabled: true
#     groupBars: true
#     labelSize: 9pt
#     showLegend: true
#     color_application:
#       collection_id: 7c56cc21-66e4-41c9-81ce-a60e1c3967b2
#       custom:
#         id: a321a215-0d03-1afa-70b0-a7bd3f198485
#         label: Custom
#         type: discrete
#         colors:
#         - "#E52592"
#         - "#7CB342"
#         - "#9334E6"
#         - "#80868B"
#         - "#079c98"
#         - "#A8A116"
#         - "#EA4335"
#         - "#FF8168"
#       options:
#         steps: 5
#         reverse: false
#     x_axis_gridlines: false
#     y_axis_gridlines: true
#     show_view_names: false
#     show_y_axis_labels: true
#     show_y_axis_ticks: true
#     y_axis_tick_density: default
#     y_axis_tick_density_custom: 5
#     show_x_axis_label: true
#     show_x_axis_ticks: true
#     y_axis_scale_mode: linear
#     x_axis_reversed: false
#     y_axis_reversed: false
#     plot_size_by_field: false
#     trellis: ''
#     stacking: normal
#     limit_displayed_rows: false
#     legend_position: center
#     point_style: none
#     show_value_labels: false
#     label_density: 25
#     x_axis_scale: auto
#     y_axis_combined: true
#     show_null_points: false
#     interpolation: linear
#     show_totals_labels: false
#     show_silhouette: false
#     totals_color: "#808080"
#     x_axis_zoom: true
#     y_axis_zoom: true
#     series_colors:
#       Row Total - orders.count: "#12B5CB"
#       Row Total - orders.count_over_30: "#E52592"
#     reference_lines: [{reference_type: line, range_start: max, range_end: min, margin_top: deviation,
#         margin_value: mean, margin_bottom: deviation, label_position: right, color: "#000000",
#         line_value: '30'}]
#     trend_lines: []
#     ordering: none
#     show_null_labels: false
#     show_row_numbers: true
#     truncate_column_names: false
#     hide_totals: false
#     hide_row_totals: false
#     table_theme: gray
#     enable_conditional_formatting: false
#     conditional_formatting_include_totals: false
#     conditional_formatting_include_nulls: false
#     defaults_version: 1
#     hidden_fields:
#     hidden_pivots: {}
#     listen: {}
#     row: 13
#     col: 8
#     width: 8
#     height: 6
#   - title: 2 (Copy)
#     name: 2 (Copy) (2)
#     model: kevmccarthy_sandbox
#     explore: order_items
#     type: looker_timeline
#     fields: [
#       # sum_of_order_amount
#       # ,
#       orders.created_at_year, orders.status, orders.created_at_day_of_week_index]
#     filters:
#       orders.created_at_date: ''
#       orders.created_at_week: after 2000/10/01
#       # orders.d2: ''
#     limit: 500
#     column_limit: 50
#     dynamic_fields:
#     - category: table_calculation
#       expression: if(sum(pivot_row(${orders.count}))>30, sum(pivot_row(${orders.count})),null)
#       label: count highlight
#       value_format:
#       value_format_name:
#       _kind_hint: supermeasure
#       table_calculation: count_highlight
#       _type_hint: number
#       is_disabled: true
#     # - _kind_hint: measure
#     #   _type_hint: number
#     #   based_on: orders.order_amount
#     #   expression: ''
#     #   label: Sum of Order Amount
#     #   measure: sum_of_order_amount
#     #   type: sum
#     # - category: dimension
#     #   expression: add_days(6,${orders.created_at_week})
#     #   label: end of week
#     #   value_format:
#     #   value_format_name:
#     #   dimension: end_of_week
#     #   _kind_hint: dimension
#     #   _type_hint: date
#     groupBars: true
#     labelSize: 10pt
#     showLegend: true
#     x_axis_gridlines: false
#     y_axis_gridlines: true
#     show_view_names: false
#     show_y_axis_labels: true
#     show_y_axis_ticks: true
#     y_axis_tick_density: default
#     y_axis_tick_density_custom: 5
#     show_x_axis_label: true
#     show_x_axis_ticks: true
#     y_axis_scale_mode: linear
#     x_axis_reversed: false
#     y_axis_reversed: false
#     plot_size_by_field: false
#     trellis: ''
#     stacking: normal
#     limit_displayed_rows: false
#     legend_position: center
#     point_style: none
#     show_value_labels: false
#     label_density: 25
#     x_axis_scale: auto
#     y_axis_combined: true
#     show_null_points: false
#     interpolation: linear
#     show_totals_labels: false
#     show_silhouette: false
#     totals_color: "#808080"
#     x_axis_zoom: true
#     y_axis_zoom: true
#     series_colors:
#       Row Total - orders.count: "#12B5CB"
#       Row Total - orders.count_over_30: "#E52592"
#     reference_lines: [{reference_type: line, range_start: max, range_end: min, margin_top: deviation,
#         margin_value: mean, margin_bottom: deviation, label_position: right, color: "#000000",
#         line_value: '30'}]
#     trend_lines: []
#     ordering: none
#     show_null_labels: false
#     show_row_numbers: true
#     truncate_column_names: false
#     hide_totals: false
#     hide_row_totals: false
#     table_theme: gray
#     enable_conditional_formatting: false
#     conditional_formatting_include_totals: false
#     conditional_formatting_include_nulls: false
#     defaults_version: 1
#     hidden_fields:
#     hidden_pivots: {}
#     row: 19
#     col: 8
#     width: 8
#     height: 6
