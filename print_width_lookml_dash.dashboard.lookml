- dashboard: sales_overview
  layout: static
  width: 1680
  tile_size: 65
  title: looks based dash1
  preferred_viewer: dashboards-next
  description: ''
  preferred_slug: eRfOeqWWGDDWRSWJaL1IIJ
  elements:
  - title: basic look
    name: basic look
    top: 0
    left: 0
    height: 12
    width: 24
    model: kevmccarthy_sandbox
    explore: order_items
    type: looker_grid
    fields: [products.brand, order_items.total_sale_price]
    sorts: [order_items.total_sale_price desc 0]
    limit: 500
    column_limit: 50
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
    defaults_version: 1
    listen: {}
    # row: 0
    # col: 0
    # width: 12
    # height: 11
  - name: basic look (2)
    title: basic look
    top: 13
    left: 0
    height: 12
    width: 12
    model: kevmccarthy_sandbox
    explore: order_items
    type: looker_grid
    fields: [products.brand, order_items.total_sale_price]
    sorts: [order_items.total_sale_price desc 0]
    limit: 500
    column_limit: 50
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
    defaults_version: 1
    listen: {}
    # row: 0
    # col: 12
    # width: 12
    # height: 11

  - name: basic look (3)
    title: basic look
    top: 13
    left: 1
    height: 12
    width: 12
    model: kevmccarthy_sandbox
    explore: order_items
    type: looker_grid
    fields: [products.brand, order_items.total_sale_price]
    sorts: [order_items.total_sale_price desc 0]
    limit: 500
    column_limit: 50
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
    defaults_version: 1
    listen: {}
    # row: 0
    # col: 12
    # width: 12
    # height: 11
