view: message {
  derived_table: {sql:select 1;;}
  parameter: set_message {default_value:"message unset"}
  dimension: message {
    sql: {{set_message._parameter_value}} ;;
  }
}
explore: message {}

view: t {
  derived_table: {sql:select 1 as id union all select 2;;}
  dimension: id {
    link: {
      label: "{{value}}"
      url: "/explore/kevmccarthy_sandbox/message?fields=message.message&f[message.set_message]=
      {% if value == 1 %}message for 1
      {% else %}other message
      {%endif%}
      "
    }
  }
}
explore: t {}
