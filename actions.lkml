view: actions_test {
  derived_table: {
    sql: select '1' as id ;;
  }
  dimension: id {
#from docs    https://cloud.google.com/looker/docs/reference/param-field-action?version=25.12&lookml=new#definition
    # action:  {
    #   label: "Label to Appear in Action Menu"
    #   url: "https://example.com/posts"
    #   icon_url: "https://looker.com/favicon.ico"
    #   form_url: "https://example.com/ping/{{ value }}/form.json"
    #   param: {
    #     name: "name string"
    #     value: "value string"
    #   }
    #   form_param: {
    #     name:  "name string"
    #     type: textarea | string | select
    #     label:  "possibly-localized-string"
    #     option: {
    #       name:  "name string"
    #       label:  "possibly-localized-string"
    #     }
    #     required:  yes | no
    #     description:  "possibly-localized-string"
    #     default:  "string"
    #   }
    #   user_attribute_param: {
    #     user_attribute: user_attribute_name
    #     name: "name_for_json_payload"
    #   }
    action:  {
      label: "Label to Appear in Action Menu"
      url: "https://google.com?qwe"
      # icon_url: "https://looker.com/favicon.ico"
      form_url: "gs://kevmcc_bucket/example_actions_form.json"
      # param: {
      #   name: "name string"
      #   value: "value string"
      # }
      # form_param: {
      #   name:  "name string"
      #   # type: textarea | string | select
      #   type: textarea
      #   label:  "test dynamic label: {{actions_test.id._value}} <-"
      #   option: {
      #     name:  "name string"
      #     label:  "possibly-localized-string"
      #   }
      #   # required:  yes | no
      #   required: no
      #   description:  "possibly-localized-string"
      #   default:  "string"
      # }

      # user_attribute_param: {
        # user_attribute: user_attribute_name
        # name: "name_for_json_payload"
      # }
    }
  }
}
explore:  actions_test {}
