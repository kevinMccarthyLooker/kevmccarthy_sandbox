#consider model level params.  Note that these can actually be defined outside the mmodel file and then made availbe to a model through includes...  And it is often beneficial to manage these params external to the model if you have multiple models that should share configurations in any of these params.
# model: {
#   include:             "string"
#   label:               possibly-localized-string
#   connection:          "string"
#   persist_for:         "string"
#   persist_with:        datagroup-ref
#   week_start_day:      monday or ...
#   fiscal_month_offset: number
#   case_sensitive:      yes or no
#   named_value_format:  identifier
#
#   access_grant: identifier
    # access_grant: identifier {
    #   allowed_values: ["string"]
    #   user_attribute: user-attribute-ref
    # }
#
#   datagroup: identifier
    # datagroup: identifier {
    #   max_cache_age: "string"
    #   interval_trigger: "string"

    #   sql_trigger: sql-block ;;
    # }
#
#   map_layer: identifier
#   test: identifier
#   view: identifier
#   explore: identifier
# }
