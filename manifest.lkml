

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
