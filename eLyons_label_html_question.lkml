# #didn't work - couldn't put count in
# include: "//thelook_ecommerce_autogen_files/auto_gen_views/order_items.view"
# explore: order_items {}
# view: order_items_for_eLyons_20250115 {
#   derived_table: {
#     explore_source: order_items {
#       column: status {}
#       column: count {}
#     }
#   }
#   dimension: status_with_count {
#     sql: concat(${TABLE}.status, ${TABLE}.count}) ;;
#   }
# }
# explore: order_items_explore_for_eLyons_20250115 {
#   view_name: order_items
#   join: order_items_for_eLyons_20250115 {

#   }

# }
