
view: generic_results_table {
  derived_table: {
#Reducing Dimensionality Test 20250405 -- With 10 dimensions and top 100, took 4:15 - 10 dims and .0001 took 16 minsc(200k results) - 14 dims top 10: 2 hours
    sql:
with formatted_results as (
  SELECT
  case
    when contributors[array_length(contributors)-1]='all' then 'all row'
    when metric_control=0 then 'not present in control'
    when metric_test=0 then 'not present in test'
  else 'other' end as message
  --4/11/2025 note: explicitly added custom message in dynamic setup script

  ,array_length(contributors) as num_contributors
  ,safe_divide(unexpected_difference, sum(case when contributors[array_length(contributors)-1]='all' then metric_test else null end) over()) as `unexp diff over total test`
  ,*
  ,sum(case when contributors[array_length(contributors)-1]='all' then metric_control else null end) over() as grand_total_metric_control
  ,sum(case when contributors[array_length(contributors)-1]='all' then metric_test else null end) over() as grand_total_metric_test
  ,metric_control/sum(case when contributors[array_length(contributors)-1]='all' then metric_control else null end) over() as metric_control_portion_of_total
  ,metric_test/sum(case when contributors[array_length(contributors)-1]='all' then metric_test else null end) over() as metric_test_portion_of_total

  -- ,difference-unexpected_difference as metric_test_expected
  ,safe_divide(metric_control,sum(case when contributors[array_length(contributors)-1]='all' then metric_control else null end) over()) * sum(case when contributors[array_length(contributors)-1]='all' then metric_test else null end) over()  as metric_test_expected

  ,safe_divide(metric_test, (metric_control/sum(case when contributors[array_length(contributors)-1]='all' then metric_control else null end) over()) * sum(case when contributors[array_length(contributors)-1]='all' then metric_test else null end) over()) as metric_test_percent_of_expected



    ,rank() over(order by apriori_support desc) as rank_apriori_support
    ,rank() over(order by apriori_support) as rank_apriori_support_lowest_first

  ,rank() over(order by unexpected_difference desc NULLS FIRST, metric_test DESC) as biggest_contribution_overperformers
  ,rank() over(order by unexpected_difference asc, metric_control desc) as biggest_contribution_underperformers
  ,rank() over(order by relative_unexpected_difference desc NULLS FIRST, metric_test DESC) as biggest_change_percent_overperformers
  ,rank() over(order by relative_unexpected_difference asc NULLS LAST,metric_test,metric_control desc) as biggest_change_percent_underperformers

  ,ARRAY(SELECT split(x,'=')[0] FROM UNNEST(contributors) AS x ORDER BY x) AS included_dimensions

  ,count(*) over() as count_results

  --FROM `thekitchentable.kevmccarthy_sandbox_dataset.iowa_liquor_sales_insights_F` order by biggest_change_percent_underperformers

  FROM thekitchentable.kevmccarthy_sandbox_dataset.dynamic_insights_test order by biggest_change_percent_underperformers
)
select
*
from formatted_results
-- where message <> 'other'
--order by biggest_CONTRIBution_overperformers
;;
}


  dimension: count_results {type:number hidden:yes}
  measure: count_overall_results {type:number sql:max(${count_results});;}

  dimension: apriori_support{ type:number value_format_name:percent_1}
  measure: apriori_support_min {hidden:yes type:min sql:${apriori_support};;value_format_name:percent_1}
  measure: apriori_support_max {hidden:yes type:max sql:${apriori_support};;value_format_name:percent_1}
  measure: apriori_support_measure {
    type: number
    sql: (${apriori_support_min}+${apriori_support_max})/2  ;;
    value_format_name: percent_1
    html: {{rendered_value}}{% if value != apriori_support_min._value %}(range of values included: {{apriori_support_min._rendered_value}} to {{apriori_support_max._rendered_value}}){% endif %};;
  }
  dimension: rank_apriori_support                       {type: number
    html: {{rendered_value}} <i>(of {{count_overall_results._rendered_value}})</i> ;;
  }
  dimension: rank_apriori_support_lowest_first          {type: number}
  dimension: rank_apriori_support_percentile            {
    type: number
    value_format_name: percent_1
    sql:  ${rank_apriori_support}/${count_results} ;;
    html: Top {{rendered_value}} ;;
  }

  measure: count {label: "Rows of Analysis Results" type: count}
  dimension: passed_message {}
  dimension: message                                   {}
  dimension: unexp_diff_over_total_test                {type: number
    label: "unexp diff over total test"
    sql: ${TABLE}.`unexp diff over total test` ;;
  }
  dimension: contributors                              {}
  dimension: contributors_string                              {
    sql: ARRAY_TO_STRING(${contributors},';') ;;
    html:<span style="font-size=6px">{% assign pairs = _field._value | split: ';' %}{% for entry in pairs %}{{entry }} {% if forloop.last %}{%else%}{% if format_contributors_as_lines._parameter_value == "true"  %}<br>{%else%}|{%endif%}{%endif%}{% endfor %}</span>;;
  }
  parameter: format_contributors_as_lines {
    type: yesno
  }

  dimension: metric_test                               {type: number}
  dimension: metric_control                            {type: number}
  dimension: difference                                {type: number}
  dimension: unexpected_difference                     {type: number}
  # dimension: contribution                              {type: number}#abs of difference

  dimension: relative_difference                       {type: number}
  dimension: relative_unexpected_difference            {type: number value_format_name:percent_1}

#dataset specific fields, generated from example results table
  # dimension: iowa_liquor_sales_sales_bottle_volume_ml  {type: number}
  # dimension: iowa_liquor_sales_sales_bottles_sold      {type: number}
  # dimension: iowa_liquor_sales_sales_category_name     {}
  # dimension: iowa_liquor_sales_sales_item_description  {}
  # dimension: iowa_liquor_sales_sales_pack              {type: number}
  # dimension: iowa_liquor_sales_sales_vendor_name       {}


## basic measures
  measure: metric_test_measure{type:sum sql:${metric_test};; value_format_name:decimal_2}
  measure: metric_control_measure {type:sum sql:${metric_control};;value_format_name:decimal_2}



  measure: metric_control_portion_of_total_measure {
    type: number
    sql: ${metric_control_measure}/${grand_total_metric_control_measure} ;;
    value_format_name: percent_1
  }
  measure: metric_test_portion_of_total_measure {
    type: number
    sql: ${metric_test_measure}/${grand_total_metric_test_measure} ;;
    value_format_name: percent_1
  }
  measure: difference_measure {type: sum sql: ${difference} ;; value_format_name:decimal_2}
  measure: unexpected_difference_measure {type: sum sql: ${unexpected_difference} ;; value_format_name:decimal_2}
  measure: unexpected_difference_measure_positive_only {type: number sql: case when sum(${unexpected_difference})>0 then sum(${unexpected_difference}) else null end;; value_format_name:decimal_2}
  measure: unexpected_difference_measure_negativee_only {type: number sql: case when sum(${unexpected_difference})<=0 then sum(${unexpected_difference}) else null end ;; value_format_name:decimal_2}

  # measure: contribution_measure {type: sum sql: ${contribution} ;; value_format_name:decimal_2}

  measure: relative_difference_measure {type: number
    sql: ${difference_measure}/nullif(${metric_control_measure},0) ;;
    value_format_name:percent_1
  }
  measure: relative_unexpected_difference_measure {type: number
    sql: ${unexpected_difference_measure}/nullif(${metric_control_measure},0) ;;
    value_format_name:percent_1
  }

#these should really be in LookML layer as measures, not source sql?
  dimension: metric_control_portion_of_total           {type: number}
  dimension: metric_test_portion_of_total              {type: number}
  dimension: metric_test_expected                      {type: number}
  dimension: metric_test_percent_of_expected           {type: number}





  dimension: biggest_contribution_overperformers       {type: number}
  dimension: biggest_contribution_underperformers      {type: number}
  dimension: biggest_change_percent_overperformers     {type: number}
  dimension: biggest_change_percent_underperformers    {type: number}


  #following calculation for unexpected difference (which includes a calculated for expected) https://cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-get-insights#output_for_summable_metric_contribution_analysis_models
  measure: compliment_test_change {
    type: number
    sql: ${grand_total_metric_test_measure} - ${metric_test_measure};;
  }
  measure: complement_control_change {
    type: number
    sql: ${grand_total_metric_control_measure}-${metric_control_measure} ;;
  }
  measure: complement_change_ratio {
    type: number
    sql: ${compliment_test_change} / nullif(${complement_control_change},0) ;;
  }

  measure: expected_metric_test_measure {
    type: number
    # sql: ${metric_test_measure}-${unexpected_difference_measure} ;;
    sql: ${metric_control_measure}*${complement_change_ratio} ;;
    value_format_name: decimal_2
  }



## Grand total fields
  dimension: grand_total_metric_control                      {type: number}
  dimension: grand_total_metric_test                         {type: number}

  measure: grand_total_metric_control_measure {type: max sql: ${grand_total_metric_control} ;; value_format_name:decimal_2}
  measure: grand_total_metric_test_measure {type: max sql: ${grand_total_metric_test} ;; value_format_name:decimal_2}

## End grand total fields
#Other usefule fields
  dimension: num_contributors                          {type: number}
  dimension: included_dimensions {}

}
explore: generic_results_table {}
