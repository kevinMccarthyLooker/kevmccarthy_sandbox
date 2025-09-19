# JOB Level Info (https://cloud.google.com/bigquery/docs/information-schema-jobs)

view: information_schema_job_stages {
  derived_table: {
    sql:
    -- select SESSION_USER()
      select
        job_id -- job_id : "bquxjob_2b1d1f8_1960b35569b"
        ,query
        ,total_bytes_processed
        ,total_slot_ms
      ,creation_time -- : "2025-04-06 13:06:07.586000 UTC"
      /*other fields
      -- project_id : "kevmccarthy"
      -- project_number : "559986806773"
      -- user_email : "kevmccarthy@google.com"
      -- job_type : "QUERY"
      -- statement_type : "SELECT"
      -- priority : "INTERACTIVE"
      -- start_time : "2025-04-06 13:06:07.686000 UTC"
      -- end_time : "2025-04-06 13:06:13.800000 UTC"
      -- state : "DONE"
      -- reservation_id : null
      -- error_result : null
      -- cache_hit : "false"
      -- total_bytes_billed : "10485760"
      -- transaction_id : null
      -- parent_job_id : null
      -- session_info : null
      -- dml_statistics : null
      -- total_modified_partitions : "0"
      -- bi_engine_statistics : null
      -- transferred_bytes : "0"
      -- materialized_view_statistics : null
      -- edition : null
      -- continuous_query_info : null
      -- continuous : "false"
      -- query_dialect : "GOOGLE_SQL"

      destination_table.project_id : "kevmccarthy"
      destination_table.dataset_id : "_c13347d7aad247a6116456608e66d0e66784a602"
      destination_table.table_id : "anonb495ba2abb2789a127c591cdb576bf6ed61dd70b5aa3dfbb5a2ab43ba5f5fe37"
      ,job_creation_reason.code --: "REQUESTED"
      ,query_info.resource_warning --: null
      ,query_info.optimization_details --: null
      ,query_info.query_hashes.normalized_literals --: "f40dc5391518068d5177cc6c3f5a97717fd9db8d647798acdf1196b11348cb4a"
      ,query_info.performance_insights --: null
      */
      /* other arrays fields/structs
      ,to_json(referenced_tables) as referenced_tables
      ,to_json(labels) as labels
      ,to_json(timeline) as timeline -- not clear this gives any additional info
      ,to_json(job_stages) as job_stages
      ,to_json(metadata_cache_statistics) as metadata_cache_statistics
      ,to_json(search_statistics) as metadata_cache_statistics
      */
      ,sum(job_stages.slot_ms) over(partition by job_id) as sum_slot_ms_over_job_stages_for_job
      ,job_stages.id as job_stage_id
      ,job_stages.slot_ms
      ,round(job_stages.slot_ms / nullif(sum(job_stages.slot_ms) over(partition by job_id),0) *100.0,1) as stage_percent_of_total_job_slots
      ,job_stages.name as job_stage_name
      ,job_stages.shuffle_output_bytes
      ,job_stages.shuffle_output_bytes_spilled
      ,job_stages.records_read
      ,job_stages.records_written

      ,start_ms - (min(start_ms) over(partition by job_id)) as start_ms_relative_to_overall_job_start
      ,end_ms - start_ms as stage_duration_ms
      ,end_ms - (min(start_ms) over(partition by job_id)) as end_ms_relative_to_overall_job_start

      ,job_stages.parallel_inputs
      ,job_stages.wait_ms_max
      ,job_stages.read_ms_max
      ,job_stages.compute_ms_max
      ,job_stages.write_ms_max

      ,(select string_agg((select concat(any_value(kind),string_agg(substeps," ")) from unnest(steps.substeps) substeps),"\n") from unnest(steps) steps where steps.kind='READ') as read_substeps
      ,(select string_agg((select concat(any_value(kind),string_agg(substeps," ")) from unnest(steps.substeps) substeps),"\n") from unnest(steps) steps where steps.kind not in ('READ','WRITE')) as compute_susbteps
      ,(select string_agg((select concat(any_value(kind),string_agg(substeps," ")) from unnest(steps.substeps) substeps),"\n") from unnest(steps) steps where steps.kind='WRITE') as write_substeps
      -- ,(select string_agg(substeps) from unnest(unnest(job_stages.steps).substeps) substeps)


       from kevmccarthy.`region-us`.INFORMATION_SCHEMA.JOBS
      left join unnest(job_stages) job_stages
      -- left join (select steps, row_number() over() from unnest(steps) steps) steps
      -- left join (select * from unnest(job_stages.steps)) steps
      -- left join ((select job_stages from unnest(JOBS.job_stages) job_stages)) job_stages

      --where job_id = 'bquxjob_2b1d1f8_1960b35569b'
      -- order by job_stages.id

      ;;
  }

  dimension: primary_key {primary_key: yes sql: concat(${TABLE}.job_id,${job_stage_id});;}

  # dimension: job_id {}
  # dimension: query {html: <div style="font-size: 10px;">{{value}}</div> ;;}
  # dimension_group: creation_time {type: time}
  # dimension: total_bytes_processed {type: number}
  # dimension: total_slot_ms {type: number}

  # dimension: sum_slot_ms_over_job_stages_for_job {type: number}


  dimension: job_stage_id {type: number}
  dimension: job_stage_name {}
  dimension: job_stage_type {
    sql: trim(right(${job_stage_name},length(${job_stage_name})-greatest(strpos(${job_stage_name},':'),0))) ;;
  }
  dimension: slot_ms {type: number}
    dimension: stage_percent_of_total_job_slots {type: number}
  dimension: shuffle_output_bytes {type: number}
  dimension: shuffle_output_bytes_spilled {type: number}
  dimension: records_read {type: number}
  dimension: records_written {type: number}
    dimension: start_ms_relative_to_overall_job_start {type: number}
    dimension: stage_duration_ms {type: number}
    dimension: end_ms_relative_to_overall_job_start {type: number}
  dimension: parallel_inputs {type: number}
  dimension: wait_ms_max {type: number}
  dimension: read_ms_max {type: number}
  dimension: compute_ms_max {type: number}
  dimension: write_ms_max {type: number}
    dimension: read_substeps {}
      dimension: compute_susbteps {}
    dimension: write_substeps {}



}
view: information_schema_job_stages_for_measures {
  measure: slot_ms {type: sum}
  # measure: stage_percent_of_total_job_slots {type: number}
  measure: shuffle_output_bytes {type: sum}
  measure: shuffle_output_bytes_spilled {type: sum}
  measure: records_read {type: sum}
  measure: records_written {type: sum}
  # measure: start_ms_relative_to_overall_job_start {type: sum}
  measure: stage_duration_ms {type: sum}
  # measure: end_ms_relative_to_overall_job_start {type: sum}
  # measure: parallel_inputs {type: sum}
  measure: wait_ms_max {type: sum}
  measure: read_ms_max {type: sum}
  measure: compute_ms_max {type: sum}
  measure: write_ms_max {type: sum}
  # measure: read_substeps {}
  # measure: compute_susbteps {}
  # measure: write_substeps {}
  measure: row_count {type: count}

drill_fields: [job_stages_job_level_info.job_id, job_stages_job_level_info.query,information_schema_job_stages.job_stage_id,
  information_schema_job_stages.job_stage_name, information_schema_job_stages.slot_ms,
  information_schema_job_stages.stage_duration_ms, information_schema_job_stages.wait_ms_max,
  information_schema_job_stages.records_read, information_schema_job_stages.read_ms_max,
  information_schema_job_stages.read_substeps, information_schema_job_stages.shuffle_output_bytes,
  information_schema_job_stages.shuffle_output_bytes_spilled, information_schema_job_stages.compute_ms_max,
  information_schema_job_stages.records_written, information_schema_job_stages.compute_susbteps,
  information_schema_job_stages.write_ms_max, information_schema_job_stages.write_substeps,
  information_schema_job_stages_for_measures.slot_ms]
}
view: job_stages_job_level_info {
  set: drill_to_details_fields {fields:[job_stages_job_level_info.job_id, job_stages_job_level_info.query,information_schema_job_stages.job_stage_id,
      information_schema_job_stages.job_stage_name, information_schema_job_stages.slot_ms,
      information_schema_job_stages.stage_duration_ms, information_schema_job_stages.wait_ms_max,
      information_schema_job_stages.records_read, information_schema_job_stages.read_ms_max,
      information_schema_job_stages.read_substeps, information_schema_job_stages.shuffle_output_bytes,
      information_schema_job_stages.shuffle_output_bytes_spilled, information_schema_job_stages.compute_ms_max,
      information_schema_job_stages.records_written, information_schema_job_stages.compute_susbteps,
      information_schema_job_stages.write_ms_max, information_schema_job_stages.write_substeps,
      information_schema_job_stages_for_measures.slot_ms]}
dimension: special_table_name {sql:information_schema_job_stages;;}
dimension: job_id {
  sql:
  /*special_table_name._sql{{special_table_name._sql}}*/
  {% assign field_name = _field._name %}
  {% assign view_name = _view._name %}
  {% assign special_table_name_sql = special_table_name._sql %}
  {{_field._name | replace: _view._name , special_table_name_sql }};;

  }
dimension: query {html: <div style="font-size: 10px;">{{value}}</div> ;;}
dimension_group: creation_time {type: time}
dimension: total_bytes_processed {type: number}
dimension: total_slot_ms {type: number}

dimension: sum_slot_ms_over_job_stages_for_job {type: number}
}
view: empty_base {
  # derived_table: {
    # sql:select null;;

sql_table_name:(
select
information_schema_job_stages
,information_schema_job_stages as information_schema_job_stages_for_measures
,information_schema_job_stages as job_stages_job_level_info
from ${information_schema_job_stages.SQL_TABLE_NAME});;
    # }
}
explore: information_schema {

  from: empty_base

  # sql_table_name: (select information_schema_job_stages,information_schema_job_stages as job_stages_job_level_info from information_schema_job_stages) blend ;;
  join: information_schema_job_stages {
  relationship:one_to_one
    sql:  ;;
  }
  join:job_stages_job_level_info {
    # sql:(select information_schema_job_stages,information_schema_job_stages as job_stages_job_level_info from information_schema_job_stages) blend ;;
    relationship:one_to_one
    sql:  ;;
  }
  join:information_schema_job_stages_for_measures {
    # sql:(select information_schema_job_stages,information_schema_job_stages as job_stages_job_level_info from information_schema_job_stages) blend ;;
    relationship:one_to_one
    sql:  ;;
}

}
