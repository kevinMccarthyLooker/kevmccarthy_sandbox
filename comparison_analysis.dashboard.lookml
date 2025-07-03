---
- dashboard: comparison_analysis_results
  title: comparison analysis results
  layout: newspaper
  preferred_viewer: dashboards-next
  crossfilter_enabled: true
  description: ''
  preferred_slug: XiF6HpEFuZ9UOftAThI7YG
  elements:
  - title: Unexpected Amounts in Test, Relative to Expected (Top 100 by Expected Amount)
    name: Unexpected Amounts in Test, Relative to Expected (Top 100 by Expected Amount)
    model: kevmccarthy_sandbox
    explore: analysis_results
    type: looker_bar
    fields: [generic_results_table.contributors_string, generic_results_table.unexpected_difference_measure_negativee_only,
      generic_results_table.apriori_support_measure, generic_results_table.metric_control_portion_of_total_measure,
      generic_results_table.metric_test_portion_of_total_measure, generic_results_table.metric_control_measure,
      generic_results_table.difference_measure, generic_results_table.relative_difference_measure,
      generic_results_table.unexpected_difference_measure, generic_results_table.grand_total_metric_control_measure,
      generic_results_table.grand_total_metric_test_measure, generic_results_table.expected_metric_test_measure,
      generic_results_table.unexpected_difference_measure_positive_only, generic_results_table.metric_test_measure,
      generic_results_table.num_contributors]
    filters: {}
    sorts: [generic_results_table.expected_metric_test_measure desc, generic_results_table.num_contributors]
    limit: 100
    column_limit: 50
    dynamic_fields:
    - category: table_calculation
      expression: "${generic_results_table.expected_metric_test_measure}"
      label: axis_nomalizer1
      value_format:
      value_format_name:
      _kind_hint: measure
      table_calculation: axis_nomalizer1
      _type_hint: number
      is_disabled: true
    - category: table_calculation
      expression: "${generic_results_table.unexpected_difference_measure}"
      label: axis_nomalizer2
      value_format:
      value_format_name:
      _kind_hint: measure
      table_calculation: axis_nomalizer2
      _type_hint: number
      is_disabled: true
    filter_expression: ${generic_results_table.contributors_string}!="all"
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
    stacking: normal
    limit_displayed_rows: false
    legend_position: center
    point_style: circle
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    y_axes: [{label: '', orientation: bottom, series: [{axisId: generic_results_table.unexpected_difference_measure,
            id: generic_results_table.unexpected_difference_measure, name: Unexpected
              Difference Measure}, {axisId: generic_results_table.expected_metric_test_measure,
            id: generic_results_table.expected_metric_test_measure, name: Expected
              Metric Test Measure}, {axisId: generic_results_table.metric_test_measure,
            id: generic_results_table.metric_test_measure, name: Metric Test Measure}],
        showLabels: true, showValues: true, maxValue: !!null '', unpinAxis: false,
        tickDensity: default, tickDensityCustom: 5, type: linear}]
    x_axis_zoom: true
    y_axis_zoom: true
    series_types:
      generic_results_table.metric_test_measure: scatter
    series_colors:
      axis_nomalizer1: "#ffffff"
      axis_nomalizer2: "#ffffff"
      generic_results_table.expected_metric_test_measure: "#e3e3e3"
      generic_results_table.unexpected_difference_measure: "#7CB342"
      generic_results_table.unexpected_difference_measure_negativee_only: "#EA4335"
      generic_results_table.metric_test_measure: "#1A73E8"
      generic_results_table.unexpected_difference_measure_positive_only: "#7CB342"
    series_labels:
      generic_results_table.metric_test_measure: Actual
      generic_results_table.expected_metric_test_measure: Expected
      generic_results_table.unexpected_difference_measure_negativee_only: Unexpected
        (-)
      generic_results_table.unexpected_difference_measure_positive_only: Unexpected
        (+)
    series_point_styles:
      generic_results_table.metric_test_measure: diamond
    column_group_spacing_ratio: 0.5
    advanced_vis_config: |-
      {
        legend: {
          verticalAlign: "top",
          itemStyle: {
                       font: '24pt Trebuchet MS, Verdana, sans-serif',
                    },

        },
        "chart": {
          "backgroundColor": "rgba(0, 0, 0, 0)",
          "inverted": true,
          "style": {
            "fontFamily": "inherit",
            "fontSize": "12px"
          },
          "type": "bar"
        },
        "xAxis": {
          "type": "category",
          "labels": {
            "style": {
              "fontSize": "0.8em",
              "width": "500px"
            }
          },
          "gridLineWidth": 1
        },
        "series": [{
            "color": "#EA4335",
            "id": "generic_results_table.unexpected_difference_measure_negativee_only",
            "name": "Unexpected (-)",
            "type": "bar",
            "visible": true
          },
          {
            "color": "#e3e3e3",
            "id": "generic_results_table.expected_metric_test_measure",
            "name": "Expected",
            "type": "bar",
            "visible": true
          },
          {
            "color": "#7CB342",
            "id": "generic_results_table.unexpected_difference_measure_positive_only",
            "name": "Unexpected (+)",
            "type": "bar",
            "visible": true
          },
          {
            "color": "#1A73E8",
            "id": "generic_results_table.metric_test_measure",
            "name": "Actual",
            "type": "scatter",
            "visible": true
          }
        ],
        "yAxis": [{
          "type": "linear",
          "gridLineWidth": 1
        }]
      }
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: '12'
    rows_font_size: '12'
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_sql_query_menu_options: false
    show_totals: true
    show_row_totals: true
    truncate_header: false
    minimum_column_width: 75
    series_cell_visualizations:
      generic_results_table.metric_control_portion_of_total_measure:
        is_active: true
      generic_results_table.metric_test_portion_of_total_measure:
        is_active: true
    show_null_points: true
    interpolation: linear
    hidden_pivots: {}
    defaults_version: 1
    hidden_fields: [generic_results_table.grand_total_metric_control_measure, generic_results_table.grand_total_metric_test_measure,
      generic_results_table.relative_difference_measure, generic_results_table.metric_control_portion_of_total_measure,
      generic_results_table.metric_test_portion_of_total_measure, generic_results_table.metric_control_measure,
      generic_results_table.difference_measure, generic_results_table.apriori_support_measure,
      generic_results_table.unexpected_difference_measure, generic_results_table.num_contributors]
    up_color: false
    down_color: false
    total_color: false
    listen:
      Num Contributors: generic_results_table.num_contributors
      Contributors String: generic_results_table.contributors_string
    row: 10
    col: 0
    width: 24
    height: 22
  - title: Highest Unexpected Amount (Top 50)
    name: Highest Unexpected Amount (Top 50)
    model: kevmccarthy_sandbox
    explore: analysis_results
    type: looker_bar
    fields: [generic_results_table.contributors_string, generic_results_table.biggest_contribution_overperformers,
      generic_results_table.biggest_contribution_underperformers, generic_results_table.biggest_change_percent_overperformers,
      generic_results_table.biggest_change_percent_underperformers, generic_results_table.unexpected_difference_measure_negativee_only,
      generic_results_table.apriori_support_measure, generic_results_table.metric_control_portion_of_total_measure,
      generic_results_table.metric_test_portion_of_total_measure, generic_results_table.metric_control_measure,
      generic_results_table.difference_measure, generic_results_table.relative_difference_measure,
      generic_results_table.unexpected_difference_measure, generic_results_table.grand_total_metric_control_measure,
      generic_results_table.grand_total_metric_test_measure, generic_results_table.unexpected_difference_measure_positive_only,
      generic_results_table.expected_metric_test_measure, generic_results_table.metric_test_measure,
      generic_results_table.num_contributors]
    filters: {}
    sorts: [generic_results_table.unexpected_difference_measure_positive_only desc,
      generic_results_table.num_contributors]
    limit: 50
    column_limit: 50
    dynamic_fields:
    - category: table_calculation
      expression: "${generic_results_table.expected_metric_test_measure}"
      label: axis_nomalizer1
      value_format:
      value_format_name:
      _kind_hint: measure
      table_calculation: axis_nomalizer1
      _type_hint: number
      is_disabled: true
    - category: table_calculation
      expression: "${generic_results_table.unexpected_difference_measure}"
      label: axis_nomalizer2
      value_format:
      value_format_name:
      _kind_hint: measure
      table_calculation: axis_nomalizer2
      _type_hint: number
      is_disabled: true
    filter_expression: ${generic_results_table.contributors_string}!="all"
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
    stacking: normal
    limit_displayed_rows: false
    legend_position: center
    point_style: circle
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    y_axes: [{label: '', orientation: bottom, series: [{axisId: generic_results_table.unexpected_difference_measure,
            id: generic_results_table.unexpected_difference_measure, name: Unexpected
              Difference Measure}, {axisId: generic_results_table.expected_metric_test_measure,
            id: generic_results_table.expected_metric_test_measure, name: Expected
              Metric Test Measure}, {axisId: generic_results_table.metric_test_measure,
            id: generic_results_table.metric_test_measure, name: Metric Test Measure}],
        showLabels: true, showValues: true, maxValue: !!null '', unpinAxis: false,
        tickDensity: default, tickDensityCustom: 5, type: linear}]
    x_axis_zoom: true
    y_axis_zoom: true
    hide_legend: true
    series_types:
      generic_results_table.metric_test_measure: scatter
    series_colors:
      axis_nomalizer1: "#ffffff"
      axis_nomalizer2: "#ffffff"
      generic_results_table.expected_metric_test_measure: "#e3e3e3"
      generic_results_table.unexpected_difference_measure: "#7CB342"
      generic_results_table.unexpected_difference_measure_negativee_only: "#EA4335"
      generic_results_table.metric_test_measure: "#1A73E8"
      generic_results_table.unexpected_difference_measure_positive_only: "#7CB342"
    series_labels:
      generic_results_table.metric_test_measure: Actual
      generic_results_table.expected_metric_test_measure: Expected
      generic_results_table.unexpected_difference_measure_negativee_only: Unexpected
        (-)
      generic_results_table.unexpected_difference_measure_positive_only: Unexpected
        (+)
    series_point_styles:
      generic_results_table.metric_test_measure: diamond
    column_group_spacing_ratio: 0.5
    advanced_vis_config: |-
      {
        chart: {},
        "xAxis": {
          "type": "category",
          "labels": {
            "style": {
              "fontSize": "0.8em",
              "width": "500px"
            }
          },
          "gridLineWidth": 1
        },
      }
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: '12'
    rows_font_size: '12'
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_sql_query_menu_options: false
    show_totals: true
    show_row_totals: true
    truncate_header: false
    minimum_column_width: 75
    series_cell_visualizations:
      generic_results_table.metric_control_portion_of_total_measure:
        is_active: true
      generic_results_table.metric_test_portion_of_total_measure:
        is_active: true
    show_null_points: true
    interpolation: linear
    hidden_pivots: {}
    defaults_version: 1
    hidden_fields: [generic_results_table.grand_total_metric_control_measure, generic_results_table.grand_total_metric_test_measure,
      generic_results_table.relative_difference_measure, generic_results_table.metric_control_portion_of_total_measure,
      generic_results_table.metric_test_portion_of_total_measure, generic_results_table.metric_control_measure,
      generic_results_table.difference_measure, generic_results_table.apriori_support_measure,
      generic_results_table.unexpected_difference_measure, generic_results_table.biggest_contribution_overperformers,
      generic_results_table.biggest_contribution_underperformers, generic_results_table.biggest_change_percent_overperformers,
      generic_results_table.biggest_change_percent_underperformers, generic_results_table.num_contributors]
    up_color: false
    down_color: false
    total_color: false
    listen:
      Num Contributors: generic_results_table.num_contributors
      Contributors String: generic_results_table.contributors_string
    row: 32
    col: 0
    width: 14
    height: 12
  - title: Most Negative Unexpected Amount (Top 50)
    name: Most Negative Unexpected Amount (Top 50)
    model: kevmccarthy_sandbox
    explore: analysis_results
    type: looker_bar
    fields: [generic_results_table.contributors_string, generic_results_table.biggest_contribution_overperformers,
      generic_results_table.biggest_contribution_underperformers, generic_results_table.biggest_change_percent_overperformers,
      generic_results_table.biggest_change_percent_underperformers, generic_results_table.unexpected_difference_measure_negativee_only,
      generic_results_table.apriori_support_measure, generic_results_table.metric_control_portion_of_total_measure,
      generic_results_table.metric_test_portion_of_total_measure, generic_results_table.metric_control_measure,
      generic_results_table.difference_measure, generic_results_table.relative_difference_measure,
      generic_results_table.unexpected_difference_measure, generic_results_table.grand_total_metric_control_measure,
      generic_results_table.grand_total_metric_test_measure, generic_results_table.unexpected_difference_measure_positive_only,
      generic_results_table.expected_metric_test_measure, generic_results_table.metric_test_measure,
      generic_results_table.num_contributors]
    filters: {}
    sorts: [generic_results_table.biggest_contribution_underperformers, generic_results_table.num_contributors]
    limit: 50
    column_limit: 50
    dynamic_fields:
    - category: table_calculation
      expression: "${generic_results_table.expected_metric_test_measure}"
      label: axis_nomalizer1
      value_format:
      value_format_name:
      _kind_hint: measure
      table_calculation: axis_nomalizer1
      _type_hint: number
      is_disabled: true
    - category: table_calculation
      expression: "${generic_results_table.unexpected_difference_measure}"
      label: axis_nomalizer2
      value_format:
      value_format_name:
      _kind_hint: measure
      table_calculation: axis_nomalizer2
      _type_hint: number
      is_disabled: true
    filter_expression: ${generic_results_table.contributors_string}!="all"
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
    stacking: normal
    limit_displayed_rows: false
    legend_position: center
    point_style: circle
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    y_axes: [{label: '', orientation: bottom, series: [{axisId: generic_results_table.unexpected_difference_measure,
            id: generic_results_table.unexpected_difference_measure, name: Unexpected
              Difference Measure}, {axisId: generic_results_table.expected_metric_test_measure,
            id: generic_results_table.expected_metric_test_measure, name: Expected
              Metric Test Measure}, {axisId: generic_results_table.metric_test_measure,
            id: generic_results_table.metric_test_measure, name: Metric Test Measure}],
        showLabels: true, showValues: true, maxValue: !!null '', unpinAxis: false,
        tickDensity: default, tickDensityCustom: 5, type: linear}]
    x_axis_zoom: true
    y_axis_zoom: true
    hide_legend: true
    series_types:
      generic_results_table.metric_test_measure: scatter
    series_colors:
      axis_nomalizer1: "#ffffff"
      axis_nomalizer2: "#ffffff"
      generic_results_table.expected_metric_test_measure: "#e3e3e3"
      generic_results_table.unexpected_difference_measure: "#7CB342"
      generic_results_table.unexpected_difference_measure_negativee_only: "#EA4335"
      generic_results_table.metric_test_measure: "#1A73E8"
      generic_results_table.unexpected_difference_measure_positive_only: "#7CB342"
    series_labels:
      generic_results_table.metric_test_measure: Actual
      generic_results_table.expected_metric_test_measure: Expected
      generic_results_table.unexpected_difference_measure_negativee_only: Unexpected
        (-)
      generic_results_table.unexpected_difference_measure_positive_only: Unexpected
        (+)
    series_point_styles:
      generic_results_table.metric_test_measure: diamond
    column_group_spacing_ratio: 0.5
    advanced_vis_config: |-
      {
        chart: {},
        "xAxis": {
          "type": "category",
          "labels": {
            "style": {
              "fontSize": "0.8em",
              "width": "500px"
            }
          },
          "gridLineWidth": 1
        },
      }
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: '12'
    rows_font_size: '12'
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_sql_query_menu_options: false
    show_totals: true
    show_row_totals: true
    truncate_header: false
    minimum_column_width: 75
    series_cell_visualizations:
      generic_results_table.metric_control_portion_of_total_measure:
        is_active: true
      generic_results_table.metric_test_portion_of_total_measure:
        is_active: true
    show_null_points: true
    interpolation: linear
    hidden_pivots: {}
    defaults_version: 1
    hidden_fields: [generic_results_table.grand_total_metric_control_measure, generic_results_table.grand_total_metric_test_measure,
      generic_results_table.relative_difference_measure, generic_results_table.metric_control_portion_of_total_measure,
      generic_results_table.metric_test_portion_of_total_measure, generic_results_table.metric_control_measure,
      generic_results_table.difference_measure, generic_results_table.apriori_support_measure,
      generic_results_table.unexpected_difference_measure, generic_results_table.biggest_contribution_overperformers,
      generic_results_table.biggest_contribution_underperformers, generic_results_table.biggest_change_percent_overperformers,
      generic_results_table.biggest_change_percent_underperformers, generic_results_table.num_contributors]
    up_color: false
    down_color: false
    total_color: false
    listen:
      Num Contributors: generic_results_table.num_contributors
      Contributors String: generic_results_table.contributors_string
    row: 44
    col: 0
    width: 14
    height: 12
  - title: Highest RELATIVE Unexpected (Unexpected Amount / Control)
    name: Highest RELATIVE Unexpected (Unexpected Amount / Control)
    model: kevmccarthy_sandbox
    explore: analysis_results
    type: looker_grid
    fields: [generic_results_table.contributors_string, generic_results_table.biggest_contribution_overperformers,
      generic_results_table.biggest_contribution_underperformers, generic_results_table.biggest_change_percent_overperformers,
      generic_results_table.biggest_change_percent_underperformers, generic_results_table.unexpected_difference_measure_negativee_only,
      generic_results_table.apriori_support_measure, generic_results_table.metric_control_portion_of_total_measure,
      generic_results_table.metric_test_portion_of_total_measure, generic_results_table.metric_control_measure,
      generic_results_table.difference_measure, generic_results_table.relative_difference_measure,
      generic_results_table.unexpected_difference_measure, generic_results_table.grand_total_metric_control_measure,
      generic_results_table.grand_total_metric_test_measure, generic_results_table.unexpected_difference_measure_positive_only,
      generic_results_table.expected_metric_test_measure, generic_results_table.metric_test_measure,
      generic_results_table.relative_unexpected_difference]
    filters:
      generic_results_table.format_contributors_as_lines: 'Yes'
    sorts: [generic_results_table.biggest_change_percent_overperformers]
    limit: 5000
    column_limit: 50
    dynamic_fields:
    - category: table_calculation
      expression: "${generic_results_table.expected_metric_test_measure}"
      label: axis_nomalizer1
      value_format:
      value_format_name:
      _kind_hint: measure
      table_calculation: axis_nomalizer1
      _type_hint: number
      is_disabled: true
    - category: table_calculation
      expression: "${generic_results_table.unexpected_difference_measure}"
      label: axis_nomalizer2
      value_format:
      value_format_name:
      _kind_hint: measure
      table_calculation: axis_nomalizer2
      _type_hint: number
      is_disabled: true
    show_view_names: false
    show_row_numbers: true
    transpose: false
    truncate_text: false
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: '12'
    rows_font_size: '10'
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_sql_query_menu_options: false
    show_totals: true
    show_row_totals: true
    truncate_header: false
    minimum_column_width: 25
    series_labels:
      generic_results_table.metric_test_measure: Actual
      generic_results_table.expected_metric_test_measure: Expected
      generic_results_table.unexpected_difference_measure_negativee_only: Unexpected
        (-)
      generic_results_table.unexpected_difference_measure_positive_only: Unexpected
        (+)
    series_column_widths:
      generic_results_table.contributors_string: 300
    series_cell_visualizations:
      generic_results_table.metric_control_portion_of_total_measure:
        is_active: true
      generic_results_table.metric_test_portion_of_total_measure:
        is_active: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    y_axes: [{label: '', orientation: bottom, series: [{axisId: generic_results_table.unexpected_difference_measure,
            id: generic_results_table.unexpected_difference_measure, name: Unexpected
              Difference Measure}, {axisId: generic_results_table.expected_metric_test_measure,
            id: generic_results_table.expected_metric_test_measure, name: Expected
              Metric Test Measure}, {axisId: generic_results_table.metric_test_measure,
            id: generic_results_table.metric_test_measure, name: Metric Test Measure}],
        showLabels: true, showValues: true, maxValue: !!null '', unpinAxis: false,
        tickDensity: default, tickDensityCustom: 5, type: linear}]
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
    stacking: normal
    legend_position: center
    point_style: circle
    series_colors:
      axis_nomalizer1: "#ffffff"
      axis_nomalizer2: "#ffffff"
      generic_results_table.expected_metric_test_measure: "#e3e3e3"
      generic_results_table.unexpected_difference_measure: "#7CB342"
      generic_results_table.unexpected_difference_measure_negativee_only: "#EA4335"
      generic_results_table.metric_test_measure: "#1A73E8"
      generic_results_table.unexpected_difference_measure_positive_only: "#7CB342"
    series_point_styles:
      generic_results_table.metric_test_measure: diamond
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    column_group_spacing_ratio: 0.5
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    advanced_vis_config: |-
      {
        chart: {},
        "xAxis": {
          "type": "category",
          "labels": {
            "style": {
              "fontSize": "0.8em",
              "width": "500px"
            }
          },
          "gridLineWidth": 1
        },
      }
    show_null_points: true
    interpolation: linear
    hidden_pivots: {}
    defaults_version: 1
    hidden_fields: [generic_results_table.grand_total_metric_control_measure, generic_results_table.grand_total_metric_test_measure,
      generic_results_table.relative_difference_measure, generic_results_table.metric_control_portion_of_total_measure,
      generic_results_table.metric_test_portion_of_total_measure, generic_results_table.metric_control_measure,
      generic_results_table.difference_measure, generic_results_table.apriori_support_measure,
      generic_results_table.biggest_contribution_overperformers, generic_results_table.biggest_contribution_underperformers,
      generic_results_table.biggest_change_percent_overperformers, generic_results_table.biggest_change_percent_underperformers,
      generic_results_table.unexpected_difference_measure_positive_only, generic_results_table.unexpected_difference_measure_negativee_only,
      generic_results_table.unexpected_difference_measure]
    up_color: false
    down_color: false
    total_color: false
    note_state: collapsed
    note_display: above
    note_text: Relative Difference with Tend to show small groups whose performance
      varied greatly from test.  Consider lowering apriori_support threshold to focus
      on larger groups
    listen:
      Num Contributors: generic_results_table.num_contributors
      Contributors String: generic_results_table.contributors_string
    row: 32
    col: 14
    width: 10
    height: 12
  - title: Most Negative RELATIVE Unexpected (Unexpected Amount / Control)
    name: Most Negative RELATIVE Unexpected (Unexpected Amount / Control)
    model: kevmccarthy_sandbox
    explore: analysis_results
    type: looker_grid
    fields: [generic_results_table.contributors_string, generic_results_table.biggest_contribution_overperformers,
      generic_results_table.biggest_contribution_underperformers, generic_results_table.biggest_change_percent_overperformers,
      generic_results_table.biggest_change_percent_underperformers, generic_results_table.unexpected_difference_measure_negativee_only,
      generic_results_table.apriori_support_measure, generic_results_table.metric_control_portion_of_total_measure,
      generic_results_table.metric_test_portion_of_total_measure, generic_results_table.metric_control_measure,
      generic_results_table.difference_measure, generic_results_table.relative_difference_measure,
      generic_results_table.unexpected_difference_measure, generic_results_table.grand_total_metric_control_measure,
      generic_results_table.grand_total_metric_test_measure, generic_results_table.unexpected_difference_measure_positive_only,
      generic_results_table.expected_metric_test_measure, generic_results_table.metric_test_measure,
      generic_results_table.relative_unexpected_difference]
    filters:
      generic_results_table.format_contributors_as_lines: 'Yes'
    sorts: [generic_results_table.biggest_change_percent_underperformers]
    limit: 5000
    column_limit: 50
    dynamic_fields:
    - category: table_calculation
      expression: "${generic_results_table.expected_metric_test_measure}"
      label: axis_nomalizer1
      value_format:
      value_format_name:
      _kind_hint: measure
      table_calculation: axis_nomalizer1
      _type_hint: number
      is_disabled: true
    - category: table_calculation
      expression: "${generic_results_table.unexpected_difference_measure}"
      label: axis_nomalizer2
      value_format:
      value_format_name:
      _kind_hint: measure
      table_calculation: axis_nomalizer2
      _type_hint: number
      is_disabled: true
    show_view_names: false
    show_row_numbers: true
    transpose: false
    truncate_text: false
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: '12'
    rows_font_size: '10'
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_sql_query_menu_options: false
    show_totals: true
    show_row_totals: true
    truncate_header: false
    minimum_column_width: 25
    series_labels:
      generic_results_table.metric_test_measure: Actual
      generic_results_table.expected_metric_test_measure: Expected
      generic_results_table.unexpected_difference_measure_negativee_only: Unexpected
        (-)
      generic_results_table.unexpected_difference_measure_positive_only: Unexpected
        (+)
    series_column_widths:
      generic_results_table.contributors_string: 300
    series_cell_visualizations:
      generic_results_table.metric_control_portion_of_total_measure:
        is_active: true
      generic_results_table.metric_test_portion_of_total_measure:
        is_active: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    y_axes: [{label: '', orientation: bottom, series: [{axisId: generic_results_table.unexpected_difference_measure,
            id: generic_results_table.unexpected_difference_measure, name: Unexpected
              Difference Measure}, {axisId: generic_results_table.expected_metric_test_measure,
            id: generic_results_table.expected_metric_test_measure, name: Expected
              Metric Test Measure}, {axisId: generic_results_table.metric_test_measure,
            id: generic_results_table.metric_test_measure, name: Metric Test Measure}],
        showLabels: true, showValues: true, maxValue: !!null '', unpinAxis: false,
        tickDensity: default, tickDensityCustom: 5, type: linear}]
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
    stacking: normal
    legend_position: center
    point_style: circle
    series_colors:
      axis_nomalizer1: "#ffffff"
      axis_nomalizer2: "#ffffff"
      generic_results_table.expected_metric_test_measure: "#e3e3e3"
      generic_results_table.unexpected_difference_measure: "#7CB342"
      generic_results_table.unexpected_difference_measure_negativee_only: "#EA4335"
      generic_results_table.metric_test_measure: "#1A73E8"
      generic_results_table.unexpected_difference_measure_positive_only: "#7CB342"
    series_point_styles:
      generic_results_table.metric_test_measure: diamond
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    column_group_spacing_ratio: 0.5
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    advanced_vis_config: |-
      {
        chart: {},
        "xAxis": {
          "type": "category",
          "labels": {
            "style": {
              "fontSize": "0.8em",
              "width": "500px"
            }
          },
          "gridLineWidth": 1
        },
      }
    show_null_points: true
    interpolation: linear
    hidden_pivots: {}
    defaults_version: 1
    hidden_fields: [generic_results_table.grand_total_metric_control_measure, generic_results_table.grand_total_metric_test_measure,
      generic_results_table.relative_difference_measure, generic_results_table.metric_control_portion_of_total_measure,
      generic_results_table.metric_test_portion_of_total_measure, generic_results_table.metric_control_measure,
      generic_results_table.difference_measure, generic_results_table.apriori_support_measure,
      generic_results_table.biggest_contribution_overperformers, generic_results_table.biggest_contribution_underperformers,
      generic_results_table.biggest_change_percent_overperformers, generic_results_table.biggest_change_percent_underperformers,
      generic_results_table.unexpected_difference_measure_positive_only, generic_results_table.unexpected_difference_measure_negativee_only,
      generic_results_table.unexpected_difference_measure]
    up_color: false
    down_color: false
    total_color: false
    listen:
      Num Contributors: generic_results_table.num_contributors
      Contributors String: generic_results_table.contributors_string
    row: 44
    col: 14
    width: 10
    height: 12
  - title: Top 5000 Groups Expected Amount
    name: Top 5000 Groups Expected Amount
    model: kevmccarthy_sandbox
    explore: analysis_results
    type: looker_grid
    fields: [generic_results_table.contributors_string, generic_results_table.metric_control_measure,
      generic_results_table.unexpected_difference_measure_negativee_only, generic_results_table.apriori_support_measure,
      generic_results_table.metric_control_portion_of_total_measure, generic_results_table.expected_metric_test_measure,
      generic_results_table.difference_measure, generic_results_table.relative_difference_measure,
      generic_results_table.grand_total_metric_control_measure, generic_results_table.grand_total_metric_test_measure,
      generic_results_table.unexpected_difference_measure_positive_only, generic_results_table.metric_test_measure,
      generic_results_table.metric_test_portion_of_total_measure, generic_results_table.unexpected_difference_measure,
      generic_results_table.relative_unexpected_difference_measure, generic_results_table.num_contributors]
    filters:
      generic_results_table.format_contributors_as_lines: 'Yes'
    sorts: [generic_results_table.metric_control_measure desc, generic_results_table.num_contributors]
    limit: 5000
    column_limit: 50
    dynamic_fields:
    - category: table_calculation
      expression: "${generic_results_table.expected_metric_test_measure}"
      label: axis_nomalizer1
      value_format:
      value_format_name:
      _kind_hint: measure
      table_calculation: axis_nomalizer1
      _type_hint: number
      is_disabled: true
    - category: table_calculation
      expression: "${generic_results_table.unexpected_difference_measure}"
      label: axis_nomalizer2
      value_format:
      value_format_name:
      _kind_hint: measure
      table_calculation: axis_nomalizer2
      _type_hint: number
      is_disabled: true
    - category: table_calculation
      expression: "${generic_results_table.unexpected_difference_measure}"
      label: Unexpected Difference Bar
      value_format:
      value_format_name:
      _kind_hint: measure
      table_calculation: unexpected_difference_bar
      _type_hint: number
    show_view_names: false
    show_row_numbers: true
    transpose: false
    truncate_text: false
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: '12'
    rows_font_size: '12'
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_sql_query_menu_options: false
    column_order: ["$$$_row_numbers_$$$", generic_results_table.contributors_string,
      generic_results_table.metric_control_measure, generic_results_table.metric_control_portion_of_total_measure,
      generic_results_table.expected_metric_test_measure, generic_results_table.metric_test_measure,
      generic_results_table.metric_test_portion_of_total_measure, generic_results_table.unexpected_difference_measure,
      unexpected_difference_bar, generic_results_table.relative_unexpected_difference_measure]
    show_totals: true
    show_row_totals: true
    truncate_header: false
    minimum_column_width: 75
    series_labels:
      generic_results_table.metric_test_measure: Actual
      generic_results_table.expected_metric_test_measure: Expected
      generic_results_table.unexpected_difference_measure_negativee_only: Unexpected
        (-)
      generic_results_table.unexpected_difference_measure_positive_only: Unexpected
        (+)
    series_column_widths:
      generic_results_table.contributors_string: 600
    series_cell_visualizations:
      generic_results_table.metric_control_portion_of_total_measure:
        is_active: true
        palette:
          palette_id: 39ec52fc-40e7-8ef9-254f-4cb81a0372ff
          collection_id: 7c56cc21-66e4-41c9-81ce-a60e1c3967b2
          custom_colors:
          - "#ffffff"
          - "#454144"
      generic_results_table.metric_test_portion_of_total_measure:
        is_active: true
        palette:
          palette_id: 56d0c358-10a0-4fd6-aa0b-b117bef527ab
          collection_id: 7c56cc21-66e4-41c9-81ce-a60e1c3967b2
      generic_results_table.metric_control_measure:
        is_active: false
      generic_results_table.metric_test_measure:
        is_active: false
      generic_results_table.unexpected_difference_measure:
        is_active: false
      unexpected_difference_bar:
        is_active: true
        value_display: false
        palette:
          palette_id: c65a64ce-7f46-476b-a320-41345941e5b1
          collection_id: 7c56cc21-66e4-41c9-81ce-a60e1c3967b2
    x_axis_gridlines: false
    y_axis_gridlines: true
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
    stacking: normal
    legend_position: center
    point_style: circle
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    y_axes: [{label: '', orientation: bottom, series: [{axisId: generic_results_table.unexpected_difference_measure,
            id: generic_results_table.unexpected_difference_measure, name: Unexpected
              Difference Measure}, {axisId: generic_results_table.expected_metric_test_measure,
            id: generic_results_table.expected_metric_test_measure, name: Expected
              Metric Test Measure}, {axisId: generic_results_table.metric_test_measure,
            id: generic_results_table.metric_test_measure, name: Metric Test Measure}],
        showLabels: true, showValues: true, maxValue: !!null '', unpinAxis: false,
        tickDensity: default, tickDensityCustom: 5, type: linear}]
    x_axis_zoom: true
    y_axis_zoom: true
    series_colors:
      axis_nomalizer1: "#ffffff"
      axis_nomalizer2: "#ffffff"
      generic_results_table.expected_metric_test_measure: "#e3e3e3"
      generic_results_table.unexpected_difference_measure: "#7CB342"
      generic_results_table.unexpected_difference_measure_negativee_only: "#EA4335"
      generic_results_table.metric_test_measure: "#1A73E8"
      generic_results_table.unexpected_difference_measure_positive_only: "#7CB342"
    series_point_styles:
      generic_results_table.metric_test_measure: diamond
    column_group_spacing_ratio: 0.5
    advanced_vis_config: |-
      {
        legend: {
          verticalAlign: "top",
          itemStyle: {
                       font: '24pt Trebuchet MS, Verdana, sans-serif',
                    },

        },
        "chart": {
          "backgroundColor": "rgba(0, 0, 0, 0)",
          "inverted": true,
          "style": {
            "fontFamily": "inherit",
            "fontSize": "12px"
          },
          "type": "bar"
        },
        "xAxis": {
          "type": "category",
          "labels": {
            "style": {
              "fontSize": "0.8em",
              "width": "500px"
            }
          },
          "gridLineWidth": 1
        },
        "series": [{
            "color": "#EA4335",
            "id": "generic_results_table.unexpected_difference_measure_negativee_only",
            "name": "Unexpected (-)",
            "type": "bar",
            "visible": true
          },
          {
            "color": "#e3e3e3",
            "id": "generic_results_table.expected_metric_test_measure",
            "name": "Expected",
            "type": "bar",
            "visible": true
          },
          {
            "color": "#7CB342",
            "id": "generic_results_table.unexpected_difference_measure_positive_only",
            "name": "Unexpected (+)",
            "type": "bar",
            "visible": true
          },
          {
            "color": "#1A73E8",
            "id": "generic_results_table.metric_test_measure",
            "name": "Actual",
            "type": "scatter",
            "visible": true
          }
        ],
        "yAxis": [{
          "type": "linear",
          "gridLineWidth": 1
        }]
      }
    show_null_points: true
    interpolation: linear
    hidden_pivots: {}
    defaults_version: 1
    hidden_fields: [generic_results_table.grand_total_metric_control_measure, generic_results_table.grand_total_metric_test_measure,
      generic_results_table.relative_difference_measure, generic_results_table.difference_measure,
      generic_results_table.apriori_support_measure, generic_results_table.unexpected_difference_measure_negativee_only,
      generic_results_table.unexpected_difference_measure_positive_only, generic_results_table.num_contributors]
    up_color: false
    down_color: false
    total_color: false
    listen:
      Num Contributors: generic_results_table.num_contributors
      Contributors String: generic_results_table.contributors_string
    row: 3
    col: 0
    width: 24
    height: 7
  - title: 'SPECIAL ALL ROW: Shows overall difference from Control to Test'
    name: 'SPECIAL ALL ROW: Shows overall difference from Control to Test'
    model: kevmccarthy_sandbox
    explore: analysis_results
    type: looker_grid
    fields: [generic_results_table.contributors_string, generic_results_table.metric_control_measure,
      generic_results_table.unexpected_difference_measure_negativee_only, generic_results_table.apriori_support_measure,
      generic_results_table.metric_control_portion_of_total_measure, generic_results_table.expected_metric_test_measure,
      generic_results_table.difference_measure, generic_results_table.relative_difference_measure,
      generic_results_table.grand_total_metric_control_measure, generic_results_table.grand_total_metric_test_measure,
      generic_results_table.unexpected_difference_measure_positive_only, generic_results_table.metric_test_measure,
      generic_results_table.metric_test_portion_of_total_measure, generic_results_table.unexpected_difference_measure,
      generic_results_table.relative_unexpected_difference_measure]
    filters:
      generic_results_table.num_contributors: ''
      generic_results_table.format_contributors_as_lines: 'Yes'
      generic_results_table.contributors_string: all
    sorts: [generic_results_table.metric_control_measure desc]
    limit: 5000
    column_limit: 50
    dynamic_fields:
    - category: table_calculation
      expression: "${generic_results_table.expected_metric_test_measure}"
      label: axis_nomalizer1
      value_format:
      value_format_name:
      _kind_hint: measure
      table_calculation: axis_nomalizer1
      _type_hint: number
      is_disabled: true
    - category: table_calculation
      expression: "${generic_results_table.unexpected_difference_measure}"
      label: axis_nomalizer2
      value_format:
      value_format_name:
      _kind_hint: measure
      table_calculation: axis_nomalizer2
      _type_hint: number
      is_disabled: true
    - category: table_calculation
      expression: "${generic_results_table.unexpected_difference_measure}"
      label: Unexpected Difference Bar
      value_format:
      value_format_name:
      _kind_hint: measure
      table_calculation: unexpected_difference_bar
      _type_hint: number
    show_view_names: false
    show_row_numbers: false
    transpose: false
    truncate_text: false
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: '12'
    rows_font_size: '12'
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_sql_query_menu_options: false
    column_order: ["$$$_row_numbers_$$$", generic_results_table.contributors_string,
      generic_results_table.metric_control_measure, generic_results_table.metric_control_portion_of_total_measure,
      generic_results_table.expected_metric_test_measure, generic_results_table.metric_test_measure,
      generic_results_table.metric_test_portion_of_total_measure, generic_results_table.unexpected_difference_measure,
      unexpected_difference_bar, generic_results_table.relative_unexpected_difference_measure]
    show_totals: true
    show_row_totals: true
    truncate_header: false
    minimum_column_width: 75
    series_labels:
      generic_results_table.metric_test_measure: Actual
      generic_results_table.expected_metric_test_measure: Expected
      generic_results_table.unexpected_difference_measure_negativee_only: Unexpected
        (-)
      generic_results_table.unexpected_difference_measure_positive_only: Unexpected
        (+)
      generic_results_table.contributors_string: "​"
    series_column_widths:
      generic_results_table.contributors_string: 650
    series_cell_visualizations:
      generic_results_table.metric_control_portion_of_total_measure:
        is_active: true
        palette:
          palette_id: 39ec52fc-40e7-8ef9-254f-4cb81a0372ff
          collection_id: 7c56cc21-66e4-41c9-81ce-a60e1c3967b2
          custom_colors:
          - "#ffffff"
          - "#454144"
      generic_results_table.metric_test_portion_of_total_measure:
        is_active: true
        palette:
          palette_id: 56d0c358-10a0-4fd6-aa0b-b117bef527ab
          collection_id: 7c56cc21-66e4-41c9-81ce-a60e1c3967b2
      generic_results_table.metric_control_measure:
        is_active: false
      generic_results_table.metric_test_measure:
        is_active: false
      generic_results_table.unexpected_difference_measure:
        is_active: false
      unexpected_difference_bar:
        is_active: true
        value_display: false
        palette:
          palette_id: 8714c0de-cf33-9a95-b785-ffffc696d57c
          collection_id: 7c56cc21-66e4-41c9-81ce-a60e1c3967b2
          custom_colors:
          - "#fff"
          - "#fff"
    x_axis_gridlines: false
    y_axis_gridlines: true
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
    stacking: normal
    legend_position: center
    point_style: circle
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    y_axes: [{label: '', orientation: bottom, series: [{axisId: generic_results_table.unexpected_difference_measure,
            id: generic_results_table.unexpected_difference_measure, name: Unexpected
              Difference Measure}, {axisId: generic_results_table.expected_metric_test_measure,
            id: generic_results_table.expected_metric_test_measure, name: Expected
              Metric Test Measure}, {axisId: generic_results_table.metric_test_measure,
            id: generic_results_table.metric_test_measure, name: Metric Test Measure}],
        showLabels: true, showValues: true, maxValue: !!null '', unpinAxis: false,
        tickDensity: default, tickDensityCustom: 5, type: linear}]
    x_axis_zoom: true
    y_axis_zoom: true
    series_colors:
      axis_nomalizer1: "#ffffff"
      axis_nomalizer2: "#ffffff"
      generic_results_table.expected_metric_test_measure: "#e3e3e3"
      generic_results_table.unexpected_difference_measure: "#7CB342"
      generic_results_table.unexpected_difference_measure_negativee_only: "#EA4335"
      generic_results_table.metric_test_measure: "#1A73E8"
      generic_results_table.unexpected_difference_measure_positive_only: "#7CB342"
    series_point_styles:
      generic_results_table.metric_test_measure: diamond
    column_group_spacing_ratio: 0.5
    advanced_vis_config: |-
      {
        legend: {
          verticalAlign: "top",
          itemStyle: {
                       font: '24pt Trebuchet MS, Verdana, sans-serif',
                    },

        },
        "chart": {
          "backgroundColor": "rgba(0, 0, 0, 0)",
          "inverted": true,
          "style": {
            "fontFamily": "inherit",
            "fontSize": "12px"
          },
          "type": "bar"
        },
        "xAxis": {
          "type": "category",
          "labels": {
            "style": {
              "fontSize": "0.8em",
              "width": "500px"
            }
          },
          "gridLineWidth": 1
        },
        "series": [{
            "color": "#EA4335",
            "id": "generic_results_table.unexpected_difference_measure_negativee_only",
            "name": "Unexpected (-)",
            "type": "bar",
            "visible": true
          },
          {
            "color": "#e3e3e3",
            "id": "generic_results_table.expected_metric_test_measure",
            "name": "Expected",
            "type": "bar",
            "visible": true
          },
          {
            "color": "#7CB342",
            "id": "generic_results_table.unexpected_difference_measure_positive_only",
            "name": "Unexpected (+)",
            "type": "bar",
            "visible": true
          },
          {
            "color": "#1A73E8",
            "id": "generic_results_table.metric_test_measure",
            "name": "Actual",
            "type": "scatter",
            "visible": true
          }
        ],
        "yAxis": [{
          "type": "linear",
          "gridLineWidth": 1
        }]
      }
    show_null_points: true
    interpolation: linear
    hidden_pivots: {}
    defaults_version: 1
    hidden_fields: [generic_results_table.grand_total_metric_control_measure, generic_results_table.grand_total_metric_test_measure,
      generic_results_table.relative_difference_measure, generic_results_table.difference_measure,
      generic_results_table.apriori_support_measure, generic_results_table.unexpected_difference_measure_negativee_only,
      generic_results_table.unexpected_difference_measure_positive_only]
    up_color: false
    down_color: false
    total_color: false
    listen: {}
    row: 0
    col: 0
    width: 24
    height: 3
  filters:
  - name: Num Contributors
    title: Num Contributors
    type: field_filter
    default_value: "<=3"
    allow_multiple_values: false
    required: false
    ui_config:
      type: advanced
      display: popover
      options: []
    model: kevmccarthy_sandbox
    explore: analysis_results
    listens_to_filters: []
    field: generic_results_table.num_contributors
  - name: Contributors String
    title: Contributors String
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
    model: kevmccarthy_sandbox
    explore: analysis_results
    listens_to_filters: []
    field: generic_results_table.contributors_string
