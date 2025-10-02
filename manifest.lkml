

remote_dependency: thelook_ecommerce_autogen_files {
  url: "https://github.com/kevinMccarthyLooker/thelook_ecommerce_autogen_files.git"
  ref: "master"
}

remote_dependency: km_api_explorer_remote_repo {
  url: "https://github.com/kevinMccarthyLooker/km_api_explorer_repo.git"
  ref: "master"
}

# remote_dependency: thelook_ecommerce_basic_updates {
#   url: "https://github.com/kevinMccarthyLooker/thelook_ecommerce_basic_updates.git"
#   ref: "master"
# }


# application: api-explorer2 {
#   label: "API Explorer2"
#   # file: "bundle.js"
#   file: "//km_api_explorer_remote_repo/bundle.js"
#   # url: "https://localhost:8080/dist/bundle.js"
#   entitlements: {
#     local_storage: yes
#     navigation: no
#     new_window: yes
#     new_window_external_urls: ["https://looker.com/*", "https://developer.mozilla.org/*", "https://docs.looker.com/*", "https://cloud.google.com/*"]
#     raw_api_request: yes
#     use_form_submit: yes
#     use_embeds: yes
#     use_clipboard: yes
#     core_api_methods: ["versions", "api_spec"]
#     external_api_urls : ["https://raw.githubusercontent.com","http://localhost:30000","https://localhost:8080","https://static-a.cdn.looker.app","https://docs.looker.com","https://cloud.google.com", "https://developer.mozilla.org/"]
#     oauth2_urls: []
#   }
# }
# https://looker.thekitchentable.gccbianortham.joonix.net/projects/kevmccarthy_sandbox/files/imported_projects/km_api_explorer_remote_repo/bundle.js

application: simple_extension_km {
  label: "Simple Extension km"
  url: "https://localhost:8080/bundle.js"
  # file: "bundle.js"
  entitlements: {
    core_api_methods: ["me", "run_inline_query"]
    navigation: yes
    use_embeds: yes
    use_iframes: yes
    new_window: yes
    new_window_external_urls: []
    local_storage: yes
    # external_api_urls: []
    external_api_urls : ["https://localhost:8080","http://localhost:8080"]

  }
  mount_points: {
    dashboard_vis: no
    dashboard_tile: yes
    standalone: yes
  }
}

# local_dependency:  {
#   project: "kevmccarthy_project_for_local_import_testing"
# }

constant: newline {
  value: "
    "
}

#a specific set of view names are harcoded into this. not sure how to make it more dynamic
constant: blended_field_sql_lookup {
  value: "
{%- assign field_name = _field._name | split: '.' | last -%}
{%- assign final_sql = '' -%}
{%- for i in (1..5) -%}
  {%- if i == 1 -%} {%- assign a_view = order_items_data_source -%}
  {%- elsif i == 2 -%} {%- assign a_view = events_data_source -%}
  {%- elsif i == 3 -%} {%- assign a_view = events_data_yoy -%}
  {%- elsif i == 4 -%} {%- assign a_view = order_items_data_yoy -%}
  {%- elsif i == 5 -%} {%- assign a_view = events_data_running_total -%}
  {%- elsif i == 6 -%} {%- assign a_view = order_items_data_running_total -%}
  {%- else -%}{%- break -%}
  {%- endif -%}
  {%- assign final_sql = final_sql | append: '@{newline}  ,/* from ' | append: a_view._name | append: '-> */' -%}
  {%- if  a_view[field_name]._sql -%}{%- assign final_sql = final_sql | append: a_view[field_name]._sql -%}
  {%- else                        -%}{%- assign final_sql = final_sql | append: 'null /* ' | append: field_name | append: ' declaration not found in ' | append: a_view._name | append: ' */' -%}
  {%- endif -%}
{%- endfor -%}
{%- assign final_sql = final_sql | prepend: 'coalesce(null' | append: '@{newline})' -%}
{{- final_sql -}}
  "
}
constant: blended_field_sql_lookup__alternate_string_label_for_nulls {
  value: "
  {%- assign field_name = _field._name | split: '.' | last -%}
  {%- assign final_sql = '' -%}
  {%- for i in (1..5) -%}
  {%- if i == 1 -%} {%- assign a_view = order_items_data_source -%}
  {%- elsif i == 2 -%} {%- assign a_view = events_data_source -%}
  {%- elsif i == 3 -%} {%- assign a_view = events_data_yoy -%}
  {%- elsif i == 4 -%} {%- assign a_view = order_items_data_yoy -%}
  {%- elsif i == 5 -%} {%- assign a_view = events_data_running_total -%}
  {%- elsif i == 6 -%} {%- assign a_view = order_items_data_running_total -%}
  {%- else -%}{%- break -%}
  {%- endif -%}
  {%- assign final_sql = final_sql | append: '@{newline}  ,/* from ' | append: a_view._name | append: '-> */' -%}
  {%- if  a_view[field_name]._sql -%}{%- assign final_sql = final_sql | append: a_view[field_name]._sql -%}
  {%- else                        -%}{%- assign final_sql = final_sql | append: \"'NA for Metrics from \" | append: a_view._name | append: \"' /* \" | append: field_name | append: ' declaration not found in ' | append: a_view._name | append: ' */' -%}
  {%- endif -%}
  {%- endfor -%}
  {%- assign final_sql = final_sql | prepend: 'coalesce(null' | append: '@{newline})' -%}
  {{- final_sql -}}
  "
}
constant: blend_special_source_table_basic_column_reference {
  value: "{% if  view__is_in_query._sql=='true' %}{{_field._name}}{%else%}null/*sql replaced with null because the view {{_view._name}} is not required by the query (e.g. no metrics)*/{%endif%}"
}





# localization_settings: {
#   default_locale: en
#   localization_level: permissive
# }
