# - dashboard: tile_sizes
#   title: Tile Sizes
#   layout: static
#   preferred_viewer: dashboards-next
#   tile_size: 1 #define units you will use, in pixels
#   elements:
#   - name: a1
# #{ Collapsed query def
#     explore: order_items_basic
#     type: single_value
#     fields: [order_items_basic.count]
# #}
#     top: 0
#     left: 0
#     height: 50
#     width: 500
#   - name: a2
# #{ Collapsed query def
#     explore: order_items_basic
#     type: single_value
#     fields: [order_items_basic.count]
# #}
#     top: 100
#     left: 100
#     height: 200
#     width: 200

- dashboard: tile_sizes
  title: Tile Sizes
  layout: static
  preferred_viewer: dashboards-next
  tile_size: 50 #define units you will use, in pixels
  elements:
  - name: a1
#{ Collapsed query def
    explore: order_items_basic
    type: single_value
    fields: [order_items_basic.count]
#}
    top: 0
    left: 0
    height: 1
    width: 10
  - name: a2
#{ Collapsed query def
    explore: order_items_basic
    type: single_value
    fields: [order_items_basic.count]
#}
    top: 2
    left: 2
    height: 4
    width: 4
