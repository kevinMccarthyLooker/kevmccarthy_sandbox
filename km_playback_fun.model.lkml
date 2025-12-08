connection: "default_bigquery_connection"

#updated goal: make
view: days_ago {
  dimension: extendable_source_table_test_without_prefix {sql:_ago;;}# This works. can make functional references by appending a suffix
  dimension: extendable_source_table {sql:${TABLE};;}
  derived_table: {
    sql: select * from unnest(generate_date_array('1982-07-09',current_date())) as days
   -- where {% condition date_parameter %}UNIX_SECONDS(cast(days as timestamp)){% endcondition %}
    ;;
  }
  dimension: date_parameter {
    type: date
    datatype: epoch
    sql: UNIX_SECONDS(current_timestamp()) ;;
  }
  dimension_group: days {
    timeframes: [date,week,day_of_week,day_of_month,month_num,year]
    type: time
    sql: ${extendable_source_table}.days ;;
  }
  dimension: random {sql:'random result';;

    }
  measure: total_days {type: sum sql:1;;}
  measure: fridays {type: sum sql:1;; filters: [days_day_of_week:"Friday"]}
  measure: thirteenths {type: sum sql:1;; filters: [days_day_of_month:"13"]}
  measure: friday_the_thirteenths {type: sum sql:1;; filters: [days_day_of_week:"Friday",days_day_of_month:"13"]}
  measure: leap_days {type: sum sql:1;; filters: [days_month_num:"2",days_day_of_month:"29"]}
}

view: days_ago_yoy {
  extends: [days_ago]
  dimension: extendable_source_table {sql:${TABLE}/*yoy version*/;;}
}

view: explore_helper_fields {

#this syntax works to set a view name from a foreign object (whereas making string variables isn't the same
dimension: at10 {
  sql:
{% assign test_view_name = ${test_join_annotate_days.extendable_source_table} %}
test_join_annotate_days|
{% assign test_view_name = ${days_ago.extendable_source_table} %}

{% assign test_field_name = 'random' %}
{{test_view_name[test_field_name]._sql}}
  ;;
}
  dimension: another_test {
    sql:
    {% assign a_view_name = 'days_ago.random|days_ago.extendable_source_table' %}
    {% assign a_1 = a_view_name | split: '|' | first %}
    {% assign a3 = days_ago.random._sql %}
    {% assign a4 = a_1._sql %}

    {% assign av = days_ago.extendable_source_table._sql %}--{{av}}

    {% assign av2 = days_ago.extendable_source_table._sql['random'] %}--{{av2}}

    {% assign an_field = av['random'] %}
    {% assign an_field_sql = an_field._sql %}{{an_field_sql}}

    {% assign an_field = days_ago['random'] %}
    {% assign an_field_sql = an_field._sql %}{{an_field_sql}}
    ;;
  }
  dimension: test {sql:tested_sql
    --current_field syntax: {{_field._name}}
    ;;
  }

#demos of trying to looking up different fields based on strings (still need to explicitly set view though
  dimension: array_of_views_in_explore {
    sql:
/*first part: add to array of views and map the view name*/
days_ago|{% assign view_based_on_string = days_ago %}
{% assign field_name_string = 'extendable_source_table' %}
--{% assign a_field = view_based_on_string[field_name_string] %}
--{% assign sql = a_field._sql %}{{sql}}

explore_helper_fields|{% assign view_based_on_string = explore_helper_fields %}

/*now assign the relevant view*/
--view_based_on_string: {{view_based_on_string}}
{% assign field_name_string = 'test' %}
--{% assign a_field = view_based_on_string[field_name_string] %}
--{% assign sql = a_field._sql %}{{sql}}
--t2
test_join_annotate_days|{% assign view_based_on_string = test_join_annotate_days %}
{% assign field_name_string = 'annotation_label' %}
--{% assign a_field = view_based_on_string[field_name_string] %}
--{% assign sql = a_field._sql %}{{sql}}
;;
  }
  dimension: completed_table_array {sql:/*days_ago|{% assign view_based_on_string = days_ago %}*/;;}
}

view: test_join_annotate_days {
  dimension: extendable_source_table {sql:${TABLE};;}
  derived_table: {sql:select 'labelled' as annotation_label, current_date() as annotation_date;;}
  dimension: annotation_label {sql:concat('Label: ',${extendable_source_table}.annotation_label);;}
  dimension: annotation_date {
    datatype: date
    sql:${extendable_source_table}.annotation_date;;
  }
}

view: user_queries_joined {
  derived_table: {
#should pull from table array and make extra copies of all JOINED source views
sql:
select
--{{explore_helper_fields.completed_table_array_sql}}
  {{days_ago.extendable_source_table._sql}}, {{days_ago.extendable_source_table._sql}} as {{days_ago.extendable_source_table._sql}}_for_measures
  from (select null)
  full outer join {{days_ago.extendable_source_table._sql}} on false
;;
  }
  measure: rows {type:number sql:sum(1);;}
}

view: user_query_with_where_applied {
  derived_table: {
    sql:
/* select if(1=0,user_queries_joined,null) as user_queries_filtered,     user_queries_joined as joined_but_unfiltered from user_queries_joined
union all
*/
select user_queries_joined as user_queries_filtered                         , if(1=0,user_queries_joined,null) as alt2 from ${user_queries_joined.SQL_TABLE_NAME}
        WHERE ((( UNIX_SECONDS(timestamp(joined_views_only.days))  ) >= ((UNIX_SECONDS(TIMESTAMP_ADD(TIMESTAMP_TRUNC(TIMESTAMP_TRUNC(current_timestamp(), DAY), WEEK(MONDAY)), INTERVAL (-5 * 7) DAY)))) AND ( UNIX_SECONDS(timestamp(joined_views_only.days))  ) < ((UNIX_SECONDS(TIMESTAMP_ADD(TIMESTAMP_ADD(TIMESTAMP_TRUNC(TIMESTAMP_TRUNC(current_timestamp(), DAY), WEEK(MONDAY)), INTERVAL (-5 * 7) DAY), INTERVAL (6 * 7) DAY))))))
    ;;
  }
  dimension: test {sql:'t';;}
}

view: user_grouping_applied {
  derived_table: {
    sql:
-- /*BEGIN Looker SQL ALWAYS HAVING BASED WRAPPER*/
-- /*Likely incompatable with some havin filters or pivot scenarios*/
SELECT
    *
FROM
    (SELECT
            (DATE(TIMESTAMP_SECONDS(UNIX_SECONDS(current_timestamp()) ))) AS days_ago_date_parameter,
                (DATE(user_queries_filtered.days )) AS days_ago_days_date,
                (MOD((EXTRACT(DAYOFWEEK FROM user_queries_filtered.days ) - 1) - 1 + 7, 7)) AS days_ago_days_day_of_week_index,
                (FORMAT_TIMESTAMP('%A', user_queries_filtered.days )) AS days_ago_days_day_of_week,
            COALESCE(SUM(CASE WHEN (((( FORMAT_TIMESTAMP('%A', user_queries_filtered.days ) )) = 'Friday')) AND (( EXTRACT(DAY FROM user_queries_filtered.days ) ) = 13) THEN 1 ELSE NULL END), 0) AS days_ago_friday_the_thirteenths,
            COALESCE(SUM(1), 0) AS days_ago_total_days,
            COALESCE(SUM(CASE WHEN ((( FORMAT_TIMESTAMP('%A', user_queries_filtered.days ) )) = 'Friday') THEN 1 ELSE NULL END), 0) AS days_ago_fridays

      FROM

      (select joined_views_only.* from (select user_queries_filtered.joined_views_only from user_query_with_where_applied) user_queries_filtered) as user_queries_filtered

      -- full outer join (select if(1=0, joined_but_unfiltered,null).* from (select joined_but_unfiltered from user_query_with_where_applied where 1=0)) as joined_but_unfiltered on false

  group by all
  )
    ;;
  }
  dimension: test_grouping_view {sql:'t';;}

}

view: final_combined_query {
  derived_table: {
    sql:
/*begin query wrapping*/
select user_grouping_applied.*
,if(1=0,user_query_with_where_applied,null) as user_query_with_where_applied
from (select user_grouping_applied from
(
/*rest here needs to come in after where clause*/


--;;#;;#bypass where clause
#;;
  }

dimension: final_combined_query_end {
  sql: --
select null) on false
) as user_grouping_applied) full outer join (select user_query_with_where_applied from user_query_with_where_applied where 1=0) user_query_with_where_applied on false
union all
select if(1=0,(select user_grouping_applied),null).*,user_query_with_where_applied as user_query_with_where_applied from (select user_grouping_applied from user_grouping_applied where 1=0) full outer join (select user_query_with_where_applied from user_query_with_where_applied) user_query_with_where_applied on false

  ;;
}

  dimension: test_final_combined_view {sql:'t';;}
}
view: complete_group_by {
derived_table: {
  sql:
-- select count(*) from user_grouping_applied where 1=0
select 1,2,3,4,5 from (select null)
-- union all select user_grouping_applied.*,if(1=0,user_query_with_where_applied,null) as user_query_with_where_applied from (select user_grouping_applied from user_grouping_applied) full outer join (select user_query_with_where_applied from user_query_with_where_applied where 1=0) user_query_with_where_applied on false
GROUP BY 1, 2, 3, 4
)
}
;;
}
  dimension: test_complete_group_by_view {sql:'t';;}
}



explore: days_ago {
  join: test_join_annotate_days {
    sql_on: ${test_join_annotate_days.annotation_date}=${days_ago.days_date};;
    relationship: many_to_one
  }
  join: user_queries_joined   {sql:;; relationship:one_to_one}
  join: user_query_with_where_applied {sql:;; relationship:one_to_one}
  join: explore_helper_fields {sql:;; relationship:one_to_one}
  # join: user_grouping_applied {sql:;; relationship:one_to_one}
  join: final_combined_query {sql:;; relationship:one_to_one}
  # join: complete_group_by {sql:;; relationship:one_to_one}
  join: days_ago_yoy {}

  sql_always_having:
1=1--user_query_ending_with_having
) full outer join
${final_combined_query.final_combined_query_end}
;;

#   sql_always_having:
# 1=1--user_query_ending_with_having

#   ) AS t2
#   cross join version_placeholder
#   where curr = 1
# )
# select * from (
#   select * from ${user_queries_joined.SQL_TABLE_NAME}
# union all
#   select * from ${user_queries_joined.SQL_TABLE_NAME} where ${days_ago.days_day_of_week} = "Friday"
#   ;;
}
  # dimension: max_date_filter_field {
  #   datatype: date
  #   type: date
  #   sql:cast({% date_start max_date_filter_field %}as date);;
  # }

  # dimension: date_from_filter_filter_catcher {
  #   sql:{% condition date_from_filter_itself %}{% endcondition %};;
  # }
  # dimension: date_from_filter_itself {
  #   datatype: date
  #   type: date
  #   # sql:cast({% date_start date_from_filter_itself %}as date);;
  #   sql:{{ date_from_filter_filter_catcher._sql | replace: '=','' | replace: 'DATE(','' | replace: ')','' }};;
  # }
  # dimension: created_date_less_than_filter_date_from_filter_itself {
  #   type: yesno
  #   sql: ${created_at_date}<=${date_from_filter_itself} ;;
  # }









view: v1 {
  extension: required
  dimension: measure_type {sql:basic_sum;;}
  dimension: ref_a {sql:${v2.test};;}
  dimension: ref_b {sql:${v2.test2};;}
  dimension: v1_f1 {
    sql:
      --{{measure_type._sql}}
      {% if measure_type._sql == 'basic_sum' %}--use basic sum logic / path
        ${ref_a}
      {% else %}
        ${ref_b}
      {% endif %}
      ;;

    }
  }
  view: v2 {
    dimension: measure_type {sql:${EXTENDED}_yoy;;}
    dimension: test {sql:test_update;;}
    dimension: test2 {sql:test_updater;;}
    extends: [v1]
    dimension: v1_f1 {
      sql:${EXTENDED};;
    }
    dimension: is_yoy {
      sql: no ;;
    }
  }
#THIS WOULD BE BAD APPROACH
  view: +v1 {
    dimension:numerator_field {
      # sql:yes;;/// not generic enough and cant take it away.
    }
  }

  explore: v2 {}


view: label_dynamism_doubLe_check {
  label: "{% if _field._in_query %}in query{% else %}t view label{% endif %}"
  derived_table: {
    sql: select '1' as p union all select '2' as p;;
  }
  dimension: test {
    label: "{% if _field._is_selected %}f {% else %}PickerLabel{% endif %}"
    sql:${TABLE}.p;;
  }
  measure: total {
    type: number
    sql: max(101) ;;
    html: t:{{total._rendered_value}} ;;
  }
}

explore: label_dynamism_doubLe_check {}
