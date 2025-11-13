view: wide_fiscal_calendar_wk {
  derived_table: {sql: select * from thekitchentable.kevmccarthy_sandbox_dataset.fiscal_calendar_wk_few_years;;}

  measure: count {type: count}

  dimension: cal_dt             {type: date datatype: date }
  dimension: fsc_yr_nbr         {type: number }
  dimension: fsc_mon_nbr        {type: number }
  dimension: fsc_mon_day_nbr    {type: number }
  dimension: fsc_wk_nbr         {type: number }
  dimension: wk_day_nbr         {type: number }
  dimension: fsc_yr_bgn_dt      {type: date datatype: date }
  dimension: fsc_yr_end_dt      {type: date datatype: date }
  dimension: wk_in_mon_cnt      {type: number }
  dimension: fsc_mon_wk_nbr     {type: number }
  dimension: fsc_mon_bgn_dt     {type: date datatype: date }
  dimension: fsc_mon_end_dt     {type: date datatype: date }
  dimension: fsc_wk_bgn_dt      {type: date datatype: date }
  dimension: fsc_wk_end_dt      {type: date datatype: date   primary_key: yes}
  dimension: fsc_day_nbr        {type: number }
  dimension: jul_day_nbr        {type: number }
  dimension: fsc_yr_per_nbr     {type: number }
  dimension: fsc_yr_wk_nbr      {type: number }
  dimension: ly_cal_dt          {type: date datatype: date }
  dimension: fsc_qtr_nbr        {type: number }
  dimension: fsc_hlf_yr_nbr     {type: number }
  dimension: fsc_qtr_bgn_dt     {type: date datatype: date }
  dimension: fsc_qtr_end_dt     {type: date datatype: date }
  dimension: fsc_hlf_yr_bgn_dt  {type: date datatype: date }
  dimension: fsc_hlf_yr_end_dt  {type: date datatype: date }
  dimension: l2y_cal_dt         {type: date datatype: date }
  dimension: ly_fsc_wk_end_dt   {type: date datatype: date }
  dimension: l2y_fsc_wk_end_dt  {type: date datatype: date }
}

view: i0133_wk_pgp_smy_view_fields {
  measure: count {type: count filters:[primary_key_field: "-null"]}
  dimension: primary_key_field {primary_key:yes sql: concat(${lct_nbr},${prd_grp_nbr},${fsc_wk_end_dt});; }

  dimension: fsc_wk_end_dt {    type: date datatype: date }
  # typically looker expects you to make different grains of time fields like this.  This is how it might look when you only have weekly minim
  # dimension_group: fsc_wk_end {    type: time timeframes:[raw,week,month,year] datatype: date sql:${TABLE}.fsc_wk_end_dt;;}

  dimension: lct_nbr { type: number }
  dimension: prd_grp_nbr { type: number }
  dimension: tot_sal_amt { type: number }
  measure: sum_sales {type:sum sql:${tot_sal_amt};;value_format_name:usd}
}

########
# ADDING # OF WEEKS TO TRACK EACH WEEK"S RUNNING TOTAL TO A PDT BUILT OFF OF THE BASE PHYSICAL TABLE
# This physicalization not REQUIRED, but i worred about many unnecessary joins at runtime (for logical overruns of 'running total period', so i wanted to get criteria
# i could use BEFORE joining into the base table
#If it's a large dataset, partitioning is important.
view: physical_sales_data_table_augmented_with_running_total_helpers {
  derived_table: {
    sql:
--Just cause I didn't have real data and needed to fill out what i had for better testing...
with  modified_sample as (
  select * replace(date_add(fsc_wk_end_dt,interval number week) as fsc_wk_end_dt , (0.5+rand())*tot_sal_amt as tot_sal_amt)
  from thekitchentable.kevmccarthy_sandbox_dataset.sample_sales, unnest(generate_array(-1,120)) number
  where fsc_wk_end_dt>='2024-02-03'
)
select
date_diff(fsc_mon_end_dt,i0133_wk_pgp_smy_view_data.fsc_wk_end_dt, week) as weeks_to_run_for_mon_running_total,
date_diff(fsc_qtr_end_dt,i0133_wk_pgp_smy_view_data.fsc_wk_end_dt, week) as weeks_to_run_for_qtr_running_total,
date_diff(fsc_hlf_yr_end_dt,i0133_wk_pgp_smy_view_data.fsc_wk_end_dt, week) as weeks_to_run_for_hlf_running_total,
date_diff(fsc_yr_end_dt,i0133_wk_pgp_smy_view_data.fsc_wk_end_dt, week) as weeks_to_run_for_yr_running_total,
i0133_wk_pgp_smy_view_data.*
--likely addeding other fields from the calendar table would be helpful or at least convenient
,
from
modified_sample as i0133_wk_pgp_smy_view_data
left join thekitchentable.kevmccarthy_sandbox_dataset.fiscal_calendar_wk_few_years as begin_date_fiscal_calendar_wk on begin_date_fiscal_calendar_wk.fsc_wk_end_dt=i0133_wk_pgp_smy_view_data.fsc_wk_end_dt

    ;;
    datagroup_trigger: example_datagroup
    partition_keys: ["fsc_wk_end_dt"]
  }
}
datagroup: example_datagroup {sql_trigger:select current_date();;}



###
# Prepare a result set with multiple structs... one for each time grain.
# # Duplicate the data for each of the most granular time grains for which you need running total...
# # We then nullified the 'current only' and other running total views that need to 'run' for fewer number of periods

view: i0133_wk_pgp_smy_view_data {
  # extends: [i0133_wk_pgp_smy_view_fields]

#Note: this union approach is very similar to outer join on false
# # https://discuss.google.dev/t/outer-join-on-false-or-how-i-learned-to-stop-fanning-out-and-love-the-null/114301

#Performance Note: You may realize it would be logical to do this with UNNEST logic...
# # however, filtering on 'complex' derived dates (i.e. coalesced or generated via UNNEST) do not take advantage of partitioning

# Advanced liquid in the derived table logic creates an array and then loops through the array
# # Creating many Union sql blocks with only the iteration number changed
  derived_table: {

    sql:
select
0 as periods_offset
,fsc_wk_end_dt as original_fsc_wk_end_dt
,i0133_wk_pgp_smy_view as i0133_wk_pgp_smy_view_data_running
,i0133_wk_pgp_smy_view as i0133_wk_pgp_smy_view_data_yr
,i0133_wk_pgp_smy_view as i0133_wk_pgp_smy_view_data_hlf
,i0133_wk_pgp_smy_view as i0133_wk_pgp_smy_view_data_qtr
,i0133_wk_pgp_smy_view as i0133_wk_pgp_smy_view_data_mon
,i0133_wk_pgp_smy_view as i0133_wk_pgp_smy_view_current
from
${physical_sales_data_table_augmented_with_running_total_helpers.SQL_TABLE_NAME}
as i0133_wk_pgp_smy_view

{% assign array_of_running_entries = '1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23;24;25;26;27;28;29;30;31;32;33;34;35;36;37;38;39;40;41;42;43;44;45;46;47;48;49;50;51;52' | split:';' %}
{% for entry in array_of_running_entries %}
union all
select
{{entry}} as periods_offset,
fsc_wk_end_dt as original_fsc_wk_end_dt,
                                                 ( select as struct i0133_wk_pgp_smy_view.* replace(date_add(fsc_wk_end_dt, interval {{entry}} week) as fsc_wk_end_dt)       ) as i0133_wk_pgp_smy_view_data_running,
if({{entry}}<=weeks_to_run_for_yr_running_total ,( select as struct i0133_wk_pgp_smy_view.* replace(date_add(fsc_wk_end_dt, interval {{entry}} week) as fsc_wk_end_dt)) ,null) as i0133_wk_pgp_smy_view_data_yr,
if({{entry}}<=weeks_to_run_for_hlf_running_total,( select as struct i0133_wk_pgp_smy_view.* replace(date_add(fsc_wk_end_dt, interval {{entry}} week) as fsc_wk_end_dt)) ,null) as i0133_wk_pgp_smy_view_data_hlf,
if({{entry}}<=weeks_to_run_for_qtr_running_total,( select as struct i0133_wk_pgp_smy_view.* replace(date_add(fsc_wk_end_dt, interval {{entry}} week) as fsc_wk_end_dt)) ,null) as i0133_wk_pgp_smy_view_data_qtr,
if({{entry}}<=weeks_to_run_for_mon_running_total,( select as struct i0133_wk_pgp_smy_view.* replace(date_add(fsc_wk_end_dt, interval {{entry}} week) as fsc_wk_end_dt)) ,null) as i0133_wk_pgp_smy_view_data_mon,
if({{entry}}=0                                  ,( select as struct i0133_wk_pgp_smy_view.* replace(date_add(fsc_wk_end_dt, interval {{entry}} week) as fsc_wk_end_dt)) ,null) as i0133_wk_pgp_smy_view_current
from ${physical_sales_data_table_augmented_with_running_total_helpers.SQL_TABLE_NAME} as i0133_wk_pgp_smy_view
{% endfor %}
    ;;
  }
  #held onto the original date for troubleshooting.  Might want to add other troubleshooting fields here?
  dimension: original_fsc_wk_end_dt {type:date datatype:date}
  dimension: fsc_wk_end_dt {type:date datatype:date}
}

#The final version with max number of running copies included...
view: i0133_wk_pgp_smy_view_data_running {extends: [i0133_wk_pgp_smy_view_fields]}

view: i0133_wk_pgp_smy_view_fields__dimensions_hidden {
  dimension: primary_key_field {hidden:yes}
  dimension: fsc_wk_end_dt {hidden:yes}
  dimension: lct_nbr       {hidden:yes}
  dimension: prd_grp_nbr   {hidden:yes}
  dimension: tot_sal_amt   {hidden:yes}
}
#manifest looker fields with these shell views.. but the default references looker gerenates will actually pull from the correspondingly named structs inside the i0133_wk_pgp_smy_view_data view

view: i0133_wk_pgp_smy_view_data_yr      {extends: [i0133_wk_pgp_smy_view_fields,i0133_wk_pgp_smy_view_fields__dimensions_hidden]}
view: i0133_wk_pgp_smy_view_data_hlf     {extends: [i0133_wk_pgp_smy_view_fields,i0133_wk_pgp_smy_view_fields__dimensions_hidden]}
view: i0133_wk_pgp_smy_view_data_qtr     {extends: [i0133_wk_pgp_smy_view_fields,i0133_wk_pgp_smy_view_fields__dimensions_hidden]}
view: i0133_wk_pgp_smy_view_data_mon     {extends: [i0133_wk_pgp_smy_view_fields,i0133_wk_pgp_smy_view_fields__dimensions_hidden]}
view: i0133_wk_pgp_smy_view_current      {extends: [i0133_wk_pgp_smy_view_fields,i0133_wk_pgp_smy_view_fields__dimensions_hidden]}



#Note: If you think in terms of week end date, then week_start_day param is confusing.
# We ended up not using Looker's built in weeks
# week_start_day: friday
#Final explore
explore: i0133_wk_pgp_smy_view_data {

  join: i0133_wk_pgp_smy_view_data_running {sql: ;; relationship:one_to_one}

  #gets reference week information based on the 'derived' date's week
  join: wide_fiscal_calendar_wk {
    relationship: many_to_one
    sql_on: ${wide_fiscal_calendar_wk.fsc_wk_end_dt}=${i0133_wk_pgp_smy_view_data_running.fsc_wk_end_dt} ;;
  }

  #again, we have these 'joined', but their data logically comes from a struct inside i0133_wk_pgp_smy_view_data, and we don't want them to add anything to the main from clause
  join: i0133_wk_pgp_smy_view_data_yr      {sql: ;; relationship:one_to_one}
  join: i0133_wk_pgp_smy_view_data_hlf     {sql: ;; relationship:one_to_one}
  join: i0133_wk_pgp_smy_view_data_qtr     {sql: ;; relationship:one_to_one}
  join: i0133_wk_pgp_smy_view_data_mon     {sql: ;; relationship:one_to_one}
  join: i0133_wk_pgp_smy_view_current      {sql: ;; relationship:one_to_one}
}

#Main variations beyond this:
# Period over period
# # Kevin: 1) Another level of extensions to further offset data.
# Join a different subject area like inventory that has no time transformation
# # Kevin: We think this is similar to the multi-fact table join solution discussed in other Thread (empty base, join with liquid knowing which tables are inquery)
