# ---
# - dashboard: date_grains_overview_20251108_copy
#   title: Date Grains Overview 20251108 (copy)
#   layout: newspaper
#   preferred_viewer: dashboards-next
#   # description: '{{_user_attributs['id']}}'
#   preferred_slug: DUw8Zi3ax1KiJbCXUx1P1D
#   elements:
#   - title: 'Series type: Gradient (Uses Values for Color)'
#     name: 'Series type: Gradient (Uses Values for Color)'
#     model: kevmccarthy_sandbox
#     explore: date_types
#     type: looker_timeline
#     fields: [date_types.generated_day_month, date_types.day_range, date_types.min_date,
#       date_types.max_date, date_types.day_count, date_types.generated_day_year]
#     filters:
#       date_types.generated_day_year: 2020/01/01 to 2030/01/01
#     sorts: [date_types.generated_day_month]
#     limit: 5000
#     column_limit: 50
#     dynamic_fields:
#     - category: table_calculation
#       expression: '"Year"'
#       label: row_number
#       value_format:
#       value_format_name:
#       _kind_hint: dimension
#       table_calculation: row_number
#       _type_hint: string
#     groupBars: true
#     labelSize: 10pt
#     showLegend: true
#     color_application:
#       collection_id: google
#       custom:
#         id: 07731b9e-145d-3779-b200-374236faa921
#         label: Custom
#         type: continuous
#         stops:
#         - color: "#0a2eba"
#           offset: 0
#         - color: "#959991"
#           offset: 50
#         - color: "#06e82f"
#           offset: 100
#       options:
#         steps: 5
#         reverse: true
#     # advanced_vis_config: "{yAxis: [{type: 'datetime',opposite: true}]}"
#     advanced_vis_config: "@{test_lookml_dash_constant}"

#     # test_lookml_dash_constant
#       # advanced_vis_config: "{chart: {{yAxis: [{type: 'datetime',opposite: true}]}}}"
#     # advanced_vis_config: "{\n  chart: {\n    \n  },\n  series: [{}],\n  yAxis: [{\
#     #   \ // Primary Y-axis (left)\n    type: 'datetime',\n    opposite: false,\n  \
#     #   \  // reversed: true \n  }, { // Secondary Y-axis (right)\n    linkedTo: 0,\n\
#     #   \    type: 'datetime',\n    opposite: true,\n    // reversed: true, \n    visibile:\
#     #   \ true\n  }],\n  // yAxis: {\n  //   type: 'datetime',\n  //   opposite: false,\n\
#     #   \  //   reversed: true\n  // }\n}"
#     # advanced_vis_config: "{  chart: {      },  series: [{}],  yAxis: [{type: 'datetime',    opposite: false,reversed: true   }, {type: 'datetime',    opposite: true],}}"


#     # {
#       # advanced_vis_config: "{yAxis: [{type: 'datetime',opposite: false},{linkedTo: 0,type: 'datetime',opposite: true}]}"


#       # advanced_vis_config: "{yAxis: [{type: 'datetime',opposite: false},{linkedTo:0,type: 'datetime',opposite: true}]}"
#       # advanced_vis_config: |2
#       #     {
#       #       yAxis: [{type: 'datetime',opposite: false}
#       #       ,{linkedTo: 0,type: 'datetime',opposite: true}]
#       #     }



#     show_view_names: false
#     show_row_numbers: true
#     transpose: false
#     truncate_text: true
#     hide_totals: false
#     hide_row_totals: false
#     size_to_fit: false
#     table_theme: editable
#     limit_displayed_rows: false
#     enable_conditional_formatting: false
#     header_text_alignment: left
#     header_font_size: '10'
#     rows_font_size: '8'
#     conditional_formatting_include_totals: false
#     conditional_formatting_include_nulls: false
#     show_sql_query_menu_options: false
#     show_totals: true
#     show_row_totals: true
#     truncate_header: true
#     minimum_column_width: 40
#     series_labels: {}
#     series_column_widths:
#       date_types.generated_day_year: 39
#       date_types.generated_day_month: 50
#       date_types.day_count: 40
#     series_cell_visualizations:
#       date_types.day_count:
#         is_active: false
#     hidden_pivots: {}
#     truncate_column_names: false
#     defaults_version: 1
#     x_axis_gridlines: false
#     y_axis_gridlines: true
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
#     stacking: ''
#     legend_position: center
#     point_style: none
#     show_value_labels: false
#     label_density: 25
#     x_axis_scale: auto
#     y_axis_combined: true
#     ordering: none
#     show_null_labels: false
#     show_totals_labels: false
#     show_silhouette: false
#     totals_color: "#808080"
#     hidden_fields: [date_types.generated_day_month, row_number, date_types.day_range]
#     listen: {}
#     row: 0
#     col: 0
#     width: 24
#     height: 13
#   # - title: 'Series type: Categorical (with detail column (column 2) set up)'
#   #   name: 'Series type: Categorical (with detail column (column 2) set up)'
#   #   model: kevmccarthy_sandbox
#   #   explore: date_types
#   #   type: looker_timeline
#   #   fields: [date_types.generated_day_month, date_types.day_range, date_types.min_date,
#   #     date_types.max_date, date_types.day_count, date_types.generated_day_year]
#   #   filters:
#   #     date_types.generated_day_year: 2020/01/01 to 2030/01/01
#   #   sorts: [date_types.generated_day_month]
#   #   limit: 5000
#   #   column_limit: 50
#   #   dynamic_fields:
#   #   - category: table_calculation
#   #     expression: row()<max(row())/2
#   #     label: row_number
#   #     value_format:
#   #     value_format_name:
#   #     _kind_hint: dimension
#   #     table_calculation: row_number
#   #     _type_hint: yesno
#   #   groupBars: true
#   #   labelSize: 10pt
#   #   showLegend: true
#   #   color_application:
#   #     collection_id: google
#   #     custom:
#   #       id: d219b0c6-01cd-7747-e23f-6263a429f48f
#   #       label: Custom
#   #       type: discrete
#   #       colors:
#   #       - "#0a2eba"
#   #       - "#959991"
#   #       - "#06e82f"
#   #     options:
#   #       steps: 5
#   #       reverse: false
#   #   advanced_vis_config: "{\n  chart: {\n    \n  },\n  series: [{}],\n  yAxis: [{\
#   #     \ // Primary Y-axis (left)\n    type: 'datetime',\n    opposite: false,\n  \
#   #     \  // reversed: true \n  }, { // Secondary Y-axis (right)\n    linkedTo: 0,\n\
#   #     \    type: 'datetime',\n    opposite: true,\n    // reversed: true, \n    visibile:\
#   #     \ true\n  }],\n  // yAxis: {\n  //   type: 'datetime',\n  //   opposite: false,\n\
#   #     \  //   reversed: true\n  // }\n}"
#   #   show_view_names: false
#   #   show_row_numbers: true
#   #   transpose: false
#   #   truncate_text: true
#   #   hide_totals: false
#   #   hide_row_totals: false
#   #   size_to_fit: false
#   #   table_theme: editable
#   #   limit_displayed_rows: false
#   #   enable_conditional_formatting: false
#   #   header_text_alignment: left
#   #   header_font_size: '10'
#   #   rows_font_size: '8'
#   #   conditional_formatting_include_totals: false
#   #   conditional_formatting_include_nulls: false
#   #   show_sql_query_menu_options: false
#   #   show_totals: true
#   #   show_row_totals: true
#   #   truncate_header: true
#   #   minimum_column_width: 40
#   #   series_labels: {}
#   #   series_column_widths:
#   #     date_types.generated_day_year: 39
#   #     date_types.generated_day_month: 50
#   #     date_types.day_count: 40
#   #   series_cell_visualizations:
#   #     date_types.day_count:
#   #       is_active: false
#   #   hidden_pivots: {}
#   #   truncate_column_names: false
#   #   defaults_version: 1
#   #   x_axis_gridlines: false
#   #   y_axis_gridlines: true
#   #   show_y_axis_labels: true
#   #   show_y_axis_ticks: true
#   #   y_axis_tick_density: default
#   #   y_axis_tick_density_custom: 5
#   #   show_x_axis_label: true
#   #   show_x_axis_ticks: true
#   #   y_axis_scale_mode: linear
#   #   x_axis_reversed: false
#   #   y_axis_reversed: false
#   #   plot_size_by_field: false
#   #   trellis: ''
#   #   stacking: ''
#   #   legend_position: center
#   #   point_style: none
#   #   show_value_labels: false
#   #   label_density: 25
#   #   x_axis_scale: auto
#   #   y_axis_combined: true
#   #   ordering: none
#   #   show_null_labels: false
#   #   show_totals_labels: false
#   #   show_silhouette: false
#   #   totals_color: "#808080"
#   #   hidden_fields: [date_types.generated_day_month, date_types.day_range]
#   #   listen: {}
#   #   row: 13
#   #   col: 0
#   #   width: 24
#   #   height: 13
#   # - name: ''
#   #   type: text
#   #   title_text: ''
#   #   subtitle_text: ''
#   #   body_text: '[{"type":"p","align":"start","children":[{"type":"img","url":"https://docs.cloud.google.com/static/looker/docs/images/explore-vis-timeline-menu-2214.png","children":[{"text":""}],"id":"ng94w"}],"id":"rasj7"}]'
#   #   rich_content_json: '{"format":"slate"}'
#   #   row: 26
#   #   col: 9
#   #   width: 4
#   #   height: 5
#   # - name: " (2)"
#   #   type: text
#   #   title_text: ''
#   #   subtitle_text: ''
#   #   body_text: '[{"type":"p","align":"start","children":[{"text":"Timeline charts
#   #     help you visualize the relationship between groups of events and compare the
#   #     timespans over which these events took place. A timeline visualization also
#   #     works with numbers."}],"id":"dhcen"},{"type":"p","align":"start","children":[{"text":"To
#   #     use a timeline visualization, click the ellipsis (...) in the Visualization
#   #     bar and choose "},{"text":"Timeline","bold":true},{"text":". Click "},{"text":"Edit","bold":true},{"text":" in
#   #     the upper right corner of the visualization tab to format your visualization."}],"id":"g3juc"},{"type":"p","align":"start","children":[{"text":"For
#   #     example, you can use a timeline chart to show the timespan between a customer''s
#   #     first order date and the customer''s most recent order date. Each timespan can
#   #     be colored to indicate the number of orders that the customer has placed."}],"id":"do1jo"},{"type":"p","align":"start","children":[{"text":"[Image]"}],"id":"xd8fv"},{"type":"p","align":"start","children":[{"text":"Timeline
#   #     visualizations are based on fields in the "},{"text":"Data","bold":true},{"text":" section,
#   #     and the fields must be in a particular order. Ignoring those fields that are "},{"type":"a","url":"https://docs.cloud.google.com/looker/docs/creating-visualizations#specifying_lookml_fields_to_include_in_the_visualization","target":"_blank","children":[{"text":"hidden
#   #     from the visualization"}],"id":"7nmlz"},{"text":", the timeline needs the following
#   #     fields (in order from left to right):"}],"id":"zt8vv"},{"type":"ul","children":[{"type":"li","children":[{"type":"lic","children":[{"text":"Label
#   #     field","bold":true},{"text":": A string field, such as a name. This is a mandatory
#   #     field."}],"id":"b9u6h"}],"id":"jy634"},{"type":"li","children":[{"type":"lic","children":[{"text":"Detail
#   #     field","bold":true},{"text":": A second, optional string field, which lets you
#   #     combine each row of the timeline visualization into categories. See "},{"type":"a","url":"https://docs.cloud.google.com/looker/docs/timeline-options#displaying_individual_or_multiple_bars_per_row","target":"_blank","children":[{"text":"Displaying
#   #     Individual or Multiple Bars per Row"}],"id":"klkhx"},{"text":" for more detail."}],"id":"rtgi7"}],"id":"niwer"},{"type":"li","children":[{"type":"lic","children":[{"text":"Start
#   #     field","bold":true},{"text":": A start date or number. This is a mandatory field."}],"id":"nzcm7"}],"id":"lddhc"},{"type":"li","children":[{"type":"lic","children":[{"text":"End
#   #     field","bold":true},{"text":": An end date or number. This is a mandatory field."}],"id":"r4fzz"}],"id":"pihdw"},{"type":"li","children":[{"type":"lic","children":[{"text":"Magnitude
#   #     field","bold":true},{"text":": An optional number field, which determines the
#   #     bar color on a continuum between the two colors specified in the visualization
#   #     options. See "},{"type":"a","url":"https://docs.cloud.google.com/looker/docs/timeline-options#using_colors","target":"_blank","children":[{"text":"Using
#   #     Colors"}],"id":"wxf2s"},{"text":" for more information and other options using
#   #     colors and labels."}],"id":"b16jj"}],"id":"gjdrr"}],"id":"hqx29"}]'
#   #   rich_content_json: '{"format":"slate"}'
#   #   row: 26
#   #   col: 0
#   #   width: 9
#   #   height: 8
