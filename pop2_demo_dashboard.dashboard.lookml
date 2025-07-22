---
- dashboard: pop_blog_lookml_config_20250402
  title: POP Blog LookML Config 20250402
  # layout: newspaper
  layout: static
  preferred_viewer: dashboards-next
  description: ''
  preferred_slug: dyhZ8laEHYQw6rn3XUXiwF
  tile_size: 20
  elements:
  - title: Last Month Year over Year, with dates included for reference
    name: Last Month Year over Year, with dates included for reference
    model: pop2_demo_dashboard
    explore: my_explore_with_pop
    type: looker_grid
    fields: [pop_support.periods_ago, pop_support.max_created, pop_support.pop_date_month]
    pivots: [pop_support.periods_ago]
    fill_fields: [pop_support.pop_date_month]
    sorts: [pop_support.periods_ago, pop_support.pop_date_month desc]
    limit: 500
    column_limit: 50
    dynamic_fields:
    - category: table_calculation
      expression: '"Last Month"'
      label: Last Month
      value_format:
      value_format_name:
      _kind_hint: dimension
      table_calculation: last_month
      _type_hint: string
      is_disabled: true
    show_view_names: false
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: 12
    rows_font_size: 12
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    color_application:
      collection_id: 7c56cc21-66e4-41c9-81ce-a60e1c3967b2
      palette_id: 5d189dfc-4f46-46f3-822b-bfb0b61777b1
      options:
        steps: 5
    groupBars: true
    labelSize: 10pt
    showLegend: true
    advanced_vis_config: "{chart:{},series:[{}]}"
    x_axis_gridlines: false
    y_axis_gridlines: true
    y_axes: [{label: '', orientation: left, series: [{axisId: order_items.total_sale_price,
            id: 0 - order_items.total_sale_price, name: 0 - Order Items Total Sale
              Price}, {axisId: order_items.total_sale_price, id: 1 - order_items.total_sale_price,
            name: 1 - Order Items Total Sale Price}], showLabels: true, showValues: true,
        unpinAxis: false, tickDensity: default, type: linear}, {label: !!null '',
        orientation: left, series: [{axisId: pop_support.raw_dates, id: 0 - pop_support.raw_dates,
            name: 0 - Pop Support Raw Dates}, {axisId: pop_support.raw_dates, id: 1
              - pop_support.raw_dates, name: 1 - Pop Support Raw Dates}], showLabels: true,
        showValues: true, unpinAxis: false, tickDensity: default, type: linear}]
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    x_axis_zoom: true
    y_axis_zoom: true
    trellis: ''
    stacking: ''
    legend_position: center
    point_style: circle
    show_value_labels: true
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    custom_color_enabled: true
    show_single_value_title: true
    value_format: ''
    show_comparison: true
    comparison_type: progress_percentage
    comparison_reverse_colors: false
    show_comparison_label: true
    show_null_points: true
    interpolation: linear
    hidden_pivots: {}
    defaults_version: 1
    listen: {}
    # row: 0
    # col: 0
    # width: 5
    # height: 17
    top: 0
    left: 0
  - title: New Tile
    name: New Tile
    model: pop2_demo_dashboard
    explore: my_explore_with_pop
    type: looker_line
    fields: [pop_support.pop_date_month, pop_support.explore_row_count_for_pop_demo,
      pop_support.max_created, pop_support.periods_ago]
    pivots: [pop_support.periods_ago]
    sorts: [pop_support.periods_ago, pop_support.pop_date_month desc]
    limit: 500
    column_limit: 50
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    limit_displayed_rows: false
    legend_position: center
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    show_null_points: true
    interpolation: linear
    y_axes: [{label: '', orientation: left, series: [{axisId: users.count, id: 0 -
              users.count, name: "0 - Users \n    \n    \n    \n      \n      \n \
              \     \n    \n    Users\n     Count"}, {axisId: users.count, id: 1 -
              users.count, name: "1 - Users \n    \n    \n    \n      \n      \n \
              \     \n    \n    Users\n     Count"}], showLabels: true, showValues: true,
        unpinAxis: false, tickDensity: default, tickDensityCustom: 5, type: linear},
      {label: !!null '', orientation: left, series: [{axisId: pop_support.max_created,
            id: 0 - pop_support.max_created, name: 0 - Pop Support Max Created}, {
            axisId: pop_support.max_created, id: 1 - pop_support.max_created, name: 1
              - Pop Support Max Created}], showLabels: true, showValues: true, unpinAxis: false,
        tickDensity: default, tickDensityCustom: 5, type: linear}]
    x_axis_zoom: true
    y_axis_zoom: true
    advanced_vis_config: "{\n  series: [{\n      color: \"orange\",\n      lineWidth:\
      \ 2\n    },\n    {\n      color: \"transparent\",\n      states: {\n       \
      \ hover: {\n          enabled: false\n        }\n      },\n      showInLegend:\
      \ false\n    },\n    {\n      color: \"grey\",\n      lineWidth: 2,\n      dashStyle:\
      \ \"Dash\",\n    },\n    {\n      color: \"transparent\",\n      states: {\n\
      \        hover: {\n          enabled: false\n        }\n      },\n      showInLegend:\
      \ false\n    },\n  ],\n  tooltip: {\n    shared: true,\n    format: \"<span><b><span\
      \ style=\\\"color:{points.2.color};\\\">Previous</span></b><br>{points.3.y:%Y-%m-%d}:\
      \ {points.2.y:.1f}<br><br><b><span style=\\\"color:{points.0.color};\\\">Current</span></b><br>{points.0.x:%Y-%m-%d}:\
      \ {points.0.y:.1f}</span>\"\n  },\n  xAxis: [{\n      tickLength: 0,\n     \
      \ labels: {\n        format: \"<b><span style=\\\"color: orange;\\\">{value:\
      \ %Y-%m-%d}</span></b>\"\n      },\n      type: \"datetime\"\n    },\n    {\n\
      \      opposite: true,\n      linkedTo: 0,\n      tickLength: 0,\n      type:\
      \ \"datetime\",\n      labels: {\n        format: \"<b><span style=\\\"color:\
      \ grey;\\\">{(subtract value (subtract chart.userOptions.series.3.data.0.x chart.userOptions.series.3.data.0.y)):%Y-%m-%d}</span></b>\"\
      \n      }\n    }\n  ],\n  yAxis: [{ }, \n    {\n      visible: false \n    }]\
      \ //hide secondary axis\n}\n"
    hidden_fields:
    hidden_pivots: {}
    defaults_version: 1
    listen: {}
    # row: 0
    # col: 5
    # width: 19
    # height: 17
    top: 1
    left: 1



