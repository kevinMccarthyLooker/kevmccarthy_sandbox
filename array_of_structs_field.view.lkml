
view: array_of_structs_field {
  derived_table: {
    sql: -- select 1, [0,1,2]
      select 1 as orig_id, array(select struct(1 as id,'a' as label)  union all select struct(2 as id,'b' as label))as an_array_of_structs ;;
  }

  measure: count {
    type: count
  }

  dimension: orig_id {
    type: number
    sql: ${TABLE}.orig_id ;;
  }

  dimension: an_array_of_structs {
    type: string
    sql: ${TABLE}.an_array_of_structs ;;
    # html: {{value | replace: '{','<br>'}} ;;
    html:
    {% assign x = value %}

    {% for a in x %}
      <p>

      {{a}} {{a.id}} {{a['id']}}
      </p>
    {% endfor %}
    ;;
  }

}

explore: array_of_structs_field {}
