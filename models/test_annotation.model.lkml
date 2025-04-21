connection: "sample_bigquery_connection"

view: dummy_data_for_pop {
  derived_table: {
    sql:WITH digits as (select * from unnest([0,1,2,3,4,5,6,7,8,9]) as digit)
      ,numbers_0_to_1000 as
      (
        select first_digit.digit,second_digit.digit as second_digit,third_digit.digit as third_digit,
        cast(concat(first_digit.digit,second_digit.digit,third_digit.digit) as integer) as concatted
        from digits first_digit
        cross join digits second_digit
        cross join digits third_digit
      )
      ,dummy_data_for_pop AS (select row_number() over() as row_id, timestamp_add(current_timestamp(), INTERVAL -1*concatted DAY) as a_time,* from numbers_0_to_1000)
      SELECT *,5000 + (-1 * concatted) as sales_count FROM dummy_data_for_pop
      ;;
  }
  dimension:        row_id        {type: number}
  dimension_group:  a_time        {type: time}
  dimension:        digit         {type: number}
  dimension:        second_digit  {type: number}
  dimension:        third_digit   {type: number}
  dimension:        concatted     {type: number}
  dimension:        sales_count   {type: number}

  measure: count {type: count}
  measure: sum_sales {
    type:sum
    sql:${sales_count};;
  }
}

view: +dummy_data_for_pop {dimension: row_id{primary_key:yes}}
#hide fields
view: +dummy_data_for_pop {
  dimension: digit        {hidden: yes}
  dimension: second_digit {hidden: yes}
  dimension: third_digit  {hidden: yes}
  dimension: concatted    {hidden: yes}
}




view: +dummy_data_for_pop {
  measure: sum_sales {
    # html: {{test_annotations.list_comments._rendered_value}} ;;
    html:
    {{_field._rendered_value}}<br>
    {% assign entries_array = test_annotations.list_comments._value | split: ';' %}
    {% assign array_size = entries_array | size %}
    {% if array_size >0 %}
      <div style="background-color:white;color:black">
      {% for entry in entries_array %}
        •{{entry}}<br>
      {% endfor %}
      </div>
    {%endif%}
        ;;
  }
}
view: +dummy_data_for_pop {
  measure: sum_sales {
    action:  {
      label: "Label to Appear in Action Menu"
      # url: "https://example.com/posts"
      url: "https://looker.thekitchentable.gccbianortham.joonix.net/sql/kwwc6jhbdw57yk"
      # icon_url: "https://looker.com/favicon.ico"
      # form_url: "https://example.com/ping/{{ value }}/form.json"
      param: {
        name: "name string"
        value: "value string"
      }
      form_param: {
        name:  "comment"
        type: textarea # | string | select
        required:  yes
        default: "add a comment here"
      }
      form_param: {
        name: "Point Metadata"
        type: textarea
        default: "{{ row }}"
      }
    }
    # sql: 'placeholder' ;;
  }
}

view: test_annotations {
  sql_table_name:`thekitchentable.kevmccarthy_sandbox_dataset.test_annotations`;;
  dimension: id {}
  dimension: comments {}
  dimension: another_column {}
  measure: count {type: count}
  measure: list_comments {
    type: string
    sql: string_agg(distinct ${comments},';') ;;
    html:
    {% assign entries_array = _field._value | split: ';' %}
    {% for entry in entries_array %}
      {{entry}}<br>
    {% endfor %}
        ;;
  }
}

explore: dummy_data_for_pop {
  join: test_annotations {
    sql_on: ${test_annotations.another_column}=${dummy_data_for_pop.a_time_month} ;;
    relationship: many_to_many
  }
}
