###
# Background
# - Demo created using BigQuery Public Data - eComm dataset, with focus on challenges / pain points identified in Meli Marketplace project that relies on blending may disparate sources of data at different granularities.
#
# - This is intended to demonstrate approaches in looker semantic model to achieve core foundational query capabilities required for the marketplace initiative
# - Overaching challenge is that goal is to make a seamless interface for end users covering a broad range of dimensions and metrics across many sources.
# - - Users should be able to analyze (combine, aggregate, group, filter, etc.) data in flexible ways from the disparate sources (where the underlyind data is available and it makes business sense to do so)
# - - Combining data from different sources - some sources very large and all sources having different sets of dimensional values applicable/available is a core challenge which manifests as many related pain points
#
###
# Core propositions and results principles driving these approaches...
# - It is assumed that these queries will include data from multiples large sources and we generally expect increased runtimes and/or slot_ms(which drives cost or performance depending on BQ configurations such as reservations)
# - Thus, we assume it will be worthwhile to take steps, which may themselves have downsides (mainly: some query cost for batch processes every morning, and lookml complexity) to facilitate less compute-intensive final queries
# - - Primarily, we want to minimze the amount of data to be scanned wherever possible (whilst not 'losing' required combinations/granularities of data)
# - - We ould expect to prepar a dataset which combines disparate data in advance, and apply other configurations enabling efficient queries based on expected query patterns
# - - - Primarily scan less data by organizing data in alignment we expected filters - partitioning, clustering, possibly other optimizations such as encodings, search indexes, etc).
#
###
# - (7/9) It is early work in progress...
# - - We expect more updates adding more examples/approaches
# - - Approaches that are included here may still need/deserve improvement, such as alternatives that achieve same core benefit but are easier in terms of code maintenance, etc.
# - - Code here is focused on clarifying key approaches, and therefore will not necessarily adhere to unrelated good/best practices (e.g. you SHOUlD add descriptions to every field but we won't here).
#

###
# Scenario Covered & Pain Points addressed (at least partially):
#
# - Special Dimensions:
# - - Date / Time Period
# - - - It is expected that from each source we will use One general/primary date (note the general date will also presented in different groupings like month and year... but point is we don't want multuple different date fields that combine in confusing ways.  Consider the metrics from the source and what Date the user will expect to analyze).
# - - - It seems the relevant date field has been documented in TIME PERIOD column for each metric in this sheet: https://docs.google.com/spreadsheets/d/1fg7MoFi5onTSkBdHevqLN_ojQ28Ih0hzXXxlrGJizoM/edit?hl=en&pli=1&forcehl=1&gid=1066664832#gid=1066664832&range=I:I
# - - - (see DATE_1) Demo includes consideration of scenario. where a source doesn't have date level detail (i.e. no more granular than month).  Though recent prioritized field list doesn't seem to highlight this example, we anticipate some sources - e.g. "Plan data" mending in CDD Sketch document, will not be availbale at daily grain
#
# - Dimensions that are available and consistent across multiple sources (aligned conceptually.. and same exact values for same real-world entities to achieve proper grouping) :
# - - (see Common_Dimensions_1): Prep queries will pull and align corresponding dimensions from each source
# - - Meli examples: think of Country dimension - According to Heatmap, Country is valid for every metric.
# - - User County is the representative correspoding example here: we bring in country from multiple sources into a single field in a combined dataset
#
# - Dimensions that are missing from one source or another:
# - - (see Dimensions_not_available_in_some_sources_1)
# - - Consider Meli example 'Vertical': Though it available in most sources, heatmap shows that for example Vertical is not relevant for Sessions metric.
# - - Order Status (in Order Items only) and Browser (in Events only) are corresponding examples here: we take that data from source where we have it, but we will have to simply record null in these dimensions for metrics to which they don't/can't apply (e.g. order status will be null for web sesson count... order status simply doesn't make sense on web sessons)
#
# - Basic (re-aggregateable) Metrics:
# - - (see simple_reaggregateable_metrics_1)
# - - Basic metrics can be pulled in using NDT columns in a derived table having explore_source is the true/correct source explore (as per requirements).  When running NDTs to gather data from other explores, we'll have/end up with null or 0 for the metric
# - - common measure types Count, Sum, Min, Max are typically not a special challenge for this preformance-improvement-via-physicalization (because we can aggregate to intermediate grain and physicalize, and then re-aggregate)
# - - Order Item Count and Event Count are corresponding examples here.
#
# - Metric with a Denominator (and an additional complicating factor: numerator and denominator may come from different explores):
# - - (see metrics_with_denominator_1)
# - - Meli example from Heatmp document is CVR (TX / Sessions).  We CANNOT calculate the ratio and then aggregate/sum... need to aggregate numerator and aggregate denominator and then apply division, so NDT should pull in each separately.  In some cases we'll have to enhance base/source views creating separate numerator and denominator for this purpose.
# - - Items per Event is the example here (noteably, they come from different explores)
# - - Note that technically, Avg is an example and should be handled the same way. AVG = (SUM / COUNT).  So: AVG can be reaggregated if we instead pull Sum and Count separately, reaggregate each, and then apply the division.
#
# - Metrics with Distinctness:
# - - (see metrics_with_distinctness_1)
# - - Meli has, for example 'Unique Buyers'
# - - It isn't possible to driectly pre-aggregate distinctness measures and then re-aggregate... the necessary underlying details to fully calculate uniqueness cannot be retained whilst achieving goal of reducing size of physicalization table...
# - - - Instead, we therefore propose using Hyperloglog features of BigQuery.  it CAN let us re-aggregate and achieve close approximation of distinct counts. Not ideal but assuming it is acceptable to users it will allow or to achive our goal of reasonable performance

    connection: "kevmccarthy_bq"
    datagroup: marketplace_projects_standard_build_trigger { # We should try to establish a single common trigger criteria...
      sql_trigger: select current_date() ;; # need a query with one cell result where value changes exactly when we want to trigger.  If midnight is not the ideal time, This could check an etl table, or sql could be adjust such that the result value changes at exactly a certain time in the day (e.g. something like select date_trunc(timestamp_sub(current_timestamp(), interval 2 hours), day) ... to cause trigger at 2:00 am)
    }
    # - A principle/goal is to minimize processing and we have established that nightly batch processing will be sufficient across the entire initiative (ie current day data is not required).  We should not initiate more builds or bypass available cached results if we don't need to.
    # - Using a single datagroup has the benefit that Looker will automatically manage build order based on dependencies of one build on other builds within a datagroup
    persist_with: marketplace_projects_standard_build_trigger # use our common trigger for optimal cache usage: result gauranteed to be same since tables won't have been updated since the last build trigger anyway
    #   access_grant: identifier #access_grants outside scope of current demo, but we may utilize access grants to control field or explore level access based on user type (user attribute values)

###
# Prerequisite_1 . Have foundational views and explores that are already established and vetted for accuracy.  Note this is not a dev task in this initiative, rather: here to set up demo.

## Below are basic/pre-existing foundational view definitions.  These are basically the minimal code versions of auto-generated lookml we'll get typically from source tables, and these views represent views defined elsewhere in Meli project irrespective of this intiiative.
view: users {
  sql_table_name:`bigquery-public-data.thelook_ecommerce.users` ;;
  dimension_group:  created_at     {type: time}
  dimension:        first_name     {}
  dimension:        last_name      {}
  dimension:        email          {}
  dimension:        age            {type: number}
  dimension:        gender         {}
  dimension:        state          {}
  dimension:        street_address {}
  dimension:        postal_code    {}
  dimension:        city           {}
  dimension:        country        {}
  dimension:        latitude       {type: number}
  dimension:        longitude      {type: number}
  dimension:        traffic_source {}
  dimension:        id             {type: number primary_key:yes}
  measure:          count          {type: count}
}

view: order_items {
  derived_table: {sql: SELECT * FROM `bigquery-public-data.thelook_ecommerce.order_items` ;;} # original source view could be a typical single physical table source with sql_table_name, but also can be a derived table like.  #Also note that referencing * or many fields in a CTE doesn't necessarily impact performance.  BQ Query engine smart enough to scan only columns it needs to provide the final outputs.
  dimension_group:  created_at        {type: time}
  dimension_group:  shipped_at        {type: time}
  dimension_group:  delivered_at      {type: time}
  dimension_group:  returned_at       {type: time}
  dimension:        order_id          {type: number}
  dimension:        user_id           {type: number}
  dimension:        product_id        {type: number}
  dimension:        inventory_item_id {type: number}
  dimension:        status            {}
  dimension:        sale_price        {type: number}
  dimension:        id                {type: number primary_key:yes}
  measure:          count             {type: count}
}

view: events {
  sql_table_name: `bigquery-public-data.thelook_ecommerce.events` ;;
  dimension_group:  created_at      {type: time}
  dimension:        user_id         {type: number}
  dimension:        sequence_number {type: number}
  dimension:        session_id      {}
  dimension:        ip_address      {}
  dimension:        city            {}
  dimension:        state           {}
  dimension:        postal_code     {}
  dimension:        browser         {}
  dimension:        traffic_source  {}
  dimension:        uri             {}
  dimension:        event_type      {}
  dimension:        id              {type: number primary_key:yes}
  measure:          count           {type: count}
}

# Demo view that requires parameter selection - Note this is not a dev task in this initiative, rather an example.
# One such scenario that has been discussed was where different summarization grains are included in the same underlying dataset
view: mockup_of_view_requiring_paramterization {
    derived_table: {
      sql:
      select 'date' as row_type, country,date(created_at) as period, count(id) as new_users_count from `bigquery-public-data.thelook_ecommerce.users` users group by all
      union all
      select 'month' as row_type, country, date_trunc(date(created_at), month) as period, count(id) as new_users_count from `bigquery-public-data.thelook_ecommerce.users` users group by all
      ;;
    }
    dimension: row_type {}
    parameter: select_row_type {
      allowed_value: {value:"date"}
      allowed_value: {value:"month"}
      default_value: "date"
    }
    dimension: row_type_matches_chosen_row_type {
      type: yesno
      sql:  case when ${row_type} = {{select_row_type._parameter_value}} then true else false end ;;
    }
    dimension: country {}
    dimension: period {}
    dimension: new_users_count {hidden:yes type:number}
    measure: total_new_users_count {type:sum sql:${new_users_count};;}
}
explore: mockup_of_view_requiring_paramterization {
  # Demoing challenge where explore requires paramter value to be set for correctness
 sql_always_where: ${mockup_of_view_requiring_paramterization.row_type_matches_chosen_row_type} ;;
}

## Below are adjustments to simple base views defined above to set up specific challenges. Note this is not a dev task in this initiative, rather: here to set up demo.

view: +order_items {dimension_group: created_at {timeframes: [month,year]}} # We expect some data source will lack daily grain (such as source providing Plan data).  Removing date and other timeframes from source explore

view: +users {measure: count_distinct_users {type: count_distinct sql: ${id} ;;}} #Setting up example distinctness measure.  We won't actually use this directly in final explore but important for demo and testing/confirming the precision of hyperloglog approximate distincts

## Below are foundational source explore definitions.  These represent existing Meli explores in which metrics and dimensions that will be used for this initiative already exist
explore: order_items {
  join: users {sql_on: ${order_items.user_id}=${users.id} ;; relationship: many_to_one}
}

explore: events {
  join: users {sql_on: ${events.user_id}=${users.id} ;; relationship: many_to_one}
}

###
# Step 1 (#1 in conceptual / data lineage order): Edits that need to be applied to base views support the demonstrated appraoches.
# - Though we need to add them to underlying objects, we do not assume the existing object functionality should be fundamentally modified unless really necessary.  Therefore these should be implemented in such a way as not to impact base explores (e.g. hidden)
# - or... Still (7/9) considering: Should we should have a layer of explicit extensions for this purpose and build ndts off those instead of official base explores?

# (metrics_with_distinctness_1) ...
# - We can't directly use standard count_distinct measures, cause they are not summmable.  This new measure will be added as part of proposed alternative: use Hyperloglog to get performant re-aggregateable count distincts (albeit with some loss of exactness/precision)
view: +users {measure: count_distinct_users_hll {type: number sql: hll_count.init(${id}) ;; }} # Need to perform init step in source explore when querying source explore where full details is available... so we'll be adding the init in a measure in the base/source view, though we really only expect to use it NDT builds.

###
# Step 2: Build persisted native derived tables to build and pre-aggregate available dimensions and measures. One NDT for each relevant source explore (the pre-existing explores, having enhancements applied as necessary in step 1)
# - Still considering (7/9):  Current Demo ndts below include placeholders for ALL fields because eventually need alignment in available columns from different sources... but unclear that alginment MUST happen at THIS step, but also i don't think there's a significant performance downside...  Seems whether to have placeholders in these NDTs is primarily a question about maintenance/code clarity.  I had thought having all fields declared in same order in every NDT would add clarity and make for easy union, but column order is impacted by column type (column vs derived_column), and looking at it now.. possibly the placeholders add confusion.

view: events_data {
  derived_table: {
    # Note: Explore source must be an existing explore in this model.  If source explores exist in other models, we should consider options and their implications, such as:
    # - Establish these PDTs in the respective source models and/or use project import to port the logic to the new target model.
    # - Use publish_as_db_view (https://cloud.google.com/looker/docs/reference/param-view-publish-as-db-view parameter) to ensure that subsequent sql query(s) for blending data can find the table's location ( I expect ${[derived_tables_view_name].SQL_TABLE_NAME} will not work)

    explore_source: events {

      column: date_date {field:events.created_at_date} # Pull each applicable date grain separately (rather than pull date and then group up from there with dimension_group... because we may not have date level detail.
      column: date_month {field:events.created_at_month}

      column: user_country {field:users.country} # (Common_Dimensions_1) 'user_country' field is pulled from every source explore where it is available/applicable
      column: user_age {field:users.age}

      derived_column: order_status {sql: string(null) ;;} # (Dimensions_not_available_in_some_sources_1) - Order status is unavailable in this source. Therefore, here we are createing placeholder column using derived_column with null values, so it can subsequently be aligned with the corresponding column from other sources.  Casted so we match datatype with actual values from other sources (when we subsequently union)
      column: event_browser {field:events.browser}

      # Note:in MELI implementation we are having many more dimensions - include specifically the dimensions that are required for the solution and are available in the source explore and are appliable metrics that are supplied by this explore source
#Still Considering (7/9).. what about when different metrics in source explore are not supported by same dimensions... is there benefit to separate derived table/queries based on dimensionality available?

      derived_column: order_items_count {sql: cast(null as int64);;} # (simple_reaggregateable_metrics_1): Simply pull in reaggregateble metrics that should be source from this explore using NDT column.  Metrics from other source explores can't/shouldn't be pulled into the NDT.  We only have placeholder derived column here to align derived tables' columns (allows union and query against unioned data without errors)
      column: events_count {field:events.count}

      column: count_distinct_users_hll {field:users.count_distinct_users_hll} # (metrics_with_distinctness_1)

      # (metrics_with_denominator_1) 'Items Per Event'... can't be built here for two resasons: source explore doesn't have Event, and also because we need to apply division after aggregating numerator and denominator separately
    }

    publish_as_db_view: yes # Facilitates subsequent sql queries that need to query the table (so that table exists even while it's being rebuild, the actual phyiscal rebuild involves creating a new physical name each time. Without this param we can't know the exact location of the current table other than getting it from looker ${[PDT].SQL_TABLE_NAME} reference in LookML)

    # Below are physicalization parameters relating to minimizing build query costs while meeting requirements (or missing important updates to historical data).  Note that, for example if source's queries are gaurnateed to be insignificant, it may be simpler and thus worthwhile to not persist, or not try to increment_keys.
    datagroup_trigger: marketplace_projects_standard_build_trigger # control rebuild frequency.  see related comments in marketplace_projects_standard_build_trigger declaration

    increment_key: "date_date" # Increment Key is used in conjuntion with increment_offset to avoid superflous re-building of previously persisted results.
    # - The value must be a time column included in the explore_source declaration, AND the source datasets / queries looker generates on for that explore_source must be optimzed for filtration on that particular date field (otherwise build queries will not really benefit from incrementing).
    # - - To be more specific for bigquery: ensure the source table is actually partitioned on the date field you use
    # - - Considering that we'll have singular general date in the final datasets: when we use increment_key in this initiative it should almost always be "date_date" (or time_period_date if that's what we end up calling it)
    increment_offset: 2 # specify # of days that should be rebuilt (ideally the minimum required to meet requirements to save build compute/cost)
    # - Ideal increment_offset number depends on the nature of the source data:
    # - - Sometimes (e.g. when upstream processes gauranteed that data older than [some_number] hours/days ago cannot have changed, or there's a specific standar of [some_number] of history that needs restatement), you'll set increment_offset equal to that [some_number] to capture the all available changes but not scan any more data than necessary.  Meli mentioned 45 day for certain explores? For explore_sources where all data is append only, I believe in theory an optimal setup could offset only 1, but to provide resilience against some timing issues I suspect it may worthwhile to rebuild 2 days anyway cause of relatively little cost in that case.)
    # - - Sometimes (e.g. when data CAN change indefintely e.g. with slowly changing dimensions and late arriving data)... Choosing offset is a balnce of cost vs business relevance of capturing updates that happened to data further in history.
    # - - Sometimes (e.g. all tables in source are append-only so no historical data restatement can really happen.. but based on build timing there is some chances of an incomplete entry e.g. for yesterday... 1 day SHOULD be sufficient (still considering (7/9) possibly 2 days is best  in this type of scenario if due to etl problem we missed yesterday's ETL or Looker build or something.. and likely cost of 1 extra day is small?)

    # Below are physicalization parameters that can be used to improve efficiency of queries that use the generated physical data table
    # - Note that applying parameters below likely adds some (relative minor) cost to build (some added complexity and some additional compute and storage for usage for metadata)...
    # - - Therefore, if the queries we will run on this source don't achieve significant benefits due to these settings (which would be mainly because they filter on these fields), then applying these settings is not good
# - - Still thinking (7/9): Will end user queries actually hit these tables directly?... or will we apply another layer of physicalization on top of these (persisting the subsequent union step)? If not user facing and therefore applying filtration and if not filtering due to incremental logic in downstream builds, then likely not helpful/good to add partitioning/clustering
    partition_keys: ["date_date"] # similar to increment key above, the singular primary/general date field, at the date granularity (possibly named time_period_date) will almost always be right partition_key (where table size and expected filtration warrants partitioning)
    cluster_keys: ["user_country"] # Include fields other than partition_key that are always/very likely to be filtered on (e.g for row_level security, field(s) that are filtered by default, or fields where filtering will be mandatory / enforced e.g. with sql_always_where in the actual usage). The order of cluster_keys matters (-> NO benefit if the first key listed is not filtered, even if other keys are).
  }
}

# Note - parameters and considerations explained in similar steps above are not repeated
view: order_items_data {
  derived_table: {
    explore_source: order_items {

      derived_column: date_date                 {sql: cast(null as timestamp) ;;}       # (DATE_1) source doesn't have date level detail so we explicitly push null.  avoid type clash in subsequent union by casting missing/null fields to match to existing datatype from other sources.
      column:         date_month                {field:order_items.created_at_month}

      column:         user_country              {field:users.country}
      column:         user_age                  {field:users.age}

      column:         order_status              {field:order_items.status}
      derived_column: event_browser             {sql: string(null) ;;}

      column:         order_items_count         {field: order_items.count}
      derived_column: events_count              {sql: cast(null as int64) ;;}

#CONSIDERING AND UPDATE (7/9): DonT WANT SAME METRIC FROM MULTIPLE SOURCE EXPLORES. DON"T THINK THAT MAKES SENSE (UNLESS THEY ARE LIKE MUTUALLY EXCLUDSIVE)"      # was: # column:         count_distinct_users_hll  {field:users.count_distinct_users_hll}
      derived_column: count_distinct_users_hll {sql:cast(null as BYTES);;} # placholder for metrics that con't come from this explore
    }

    datagroup_trigger: marketplace_projects_standard_build_trigger # Whenever persisting, want to consistently use same datagroup if possible for this initiative
# - The value must be a time column included in the explore_source declarationn... doesn't make sense to increment on the typical date_date.. not obvious what will be optimal in this case as it's hard to expect that we'll be dealing with large dataets warranting icremental loads when we only have monthly granularity
# - Minor(?) open question (7/9) (relates to niche DATE_1 - date grain not availble challenge, e.g. for plan data) what should increment key be if we don't even have date grain?... probably assess on a case by case basis cause that will be rare, and in that case maybe it's small data such that increment_key is not beneficial... for such datasets we should check if we should rebuild entirely instead of incrementing, or if we should even rebuild at all or run directly against source
    increment_key: "date_month"
    increment_offset: 2
    partition_keys: ["date_month"]
    cluster_keys: ["user_country"]
  }
  # Note: Fields could be defined here and could be beneficial, for example for testing and troubleshooting purposes.  But we do not currently plan to use this view directly in an end user explore - it is primarily to drive management of a physical pre-aggregated dataset which will be used by other views.
}

# Note - parameters and considerations explained in similar steps above are not repeated
view: mockup_of_view_requiring_paramterization_data__daily {
  derived_table: {
    explore_source: mockup_of_view_requiring_paramterization {

      column:         date_date                 {field:mockup_of_view_requiring_paramterization.period}
      derived_column: date_month                {sql:date_trunc(date_date, month);;}

      column: user_country                      {field:mockup_of_view_requiring_paramterization.country}
      # derived_column: user_age                  {sql: cast(null as int64) ;;}

      # derived_column: order_status              {sql: string(null);;}
      # derived_column: event_browser             {sql: string(null) ;;}

      # derived_column: order_items_count         {sql: cast(null as int64) ;;}
      # derived_column: events_count              {sql: cast(null as int64) ;;}

      column: total_new_users_count {field:mockup_of_view_requiring_paramterization.total_new_users_count}

#CONSIDERING AND UPDATE (7/9): DonT WANT SAME METRIC FROM MULTIPLE SOURCE EXPLORES. DON"T THINK THAT MAKES SENSE (UNLESS THEY ARE LIKE MUTUALLY EXCLUDSIVE)"      # was: # column:         count_distinct_users_hll  {field:users.count_distinct_users_hll}
      derived_column: count_distinct_users_hll {sql:cast(null as BYTES);;} # placholder for metrics that con't come from this explore

      filters: {
        field: mockup_of_view_requiring_paramterization.select_row_type
        value: "date"
      }
    }
    datagroup_trigger: marketplace_projects_standard_build_trigger
    partition_keys: ["date_date"]
    cluster_keys: ["user_country"]
  # Note: Fields could be defined here and could be beneficial, for example for testing and troubleshooting purposes.  But we do not currently plan to use this view directly in an end user explore - it is primarily to drive management of a physical pre-aggregated dataset which will be used by other views.
  }
}

###
# Step 3: Co-locate/align/blend the data from different sources, building upon the datasets prepared in Step 2, using a sql union.
# - This represents a/the final consolidated dataset that end user queries (or potentially subsequent re-aggregations) should build off of.
# - Still considering (7/9): Current Demo ndts below include placeholders for ALL fields because eventually need alignment in available columns from different sources... but unclear that alginment MUST happen at THIS step, but also i don't think there's a significant performance downside...  Seems whether to have placeholders in these NDTs is primarily a question about maintenance/code clarity.  I had thought having all fields declared in same order in every NDT would add clarity and make for easy union, but column order is impacted by column type (column vs derived_column), and looking at it now.. possibly the placeholders add confusion.
# - Still considering (7/9): Can we and should we try to inherit other settings (e.g. lables and descriptions) from the source explores?  Theoretically we could do this by making this table extend the base view where the field was ultimately defined
# - - But not as simple as it sounds and likely this opens a lot of weird scenarios, such as: in case of type:AVG metrics, we are going to have to recaluclate it ourselves as type:number sql:sum()/count() .  Inheriting Type:AVG cause issues.

view: blended_data {
  derived_table: {
    sql:
select date_date,date_month,user_country,order_status,event_browser,order_items_count,events_count,count_distinct_users_hll, cast(null as Int64) as total_new_users_count from ${order_items_data.SQL_TABLE_NAME}
WHERE {% incrementcondition %} cast(date_date as TIMESTAMP) {%  endincrementcondition %}
union all
select date_date,date_month,user_country,order_status,event_browser,order_items_count,events_count,count_distinct_users_hll, cast(null as Int64) as total_new_users_count from ${events_data.SQL_TABLE_NAME}
union all
select timestamp(date_date),timestamp(date_month),user_country,cast(null as string) as order_status,cast(null as string) as event_browser,cast(null as Int64) as order_items_count,cast(null as Int64) as events_count,cast(null as BYTES) as count_distinct_users_hll, total_new_users_count from ${mockup_of_view_requiring_paramterization_data__daily.SQL_TABLE_NAME}

    ;;
    datagroup_trigger: marketplace_projects_standard_build_trigger
    increment_key: "date_date"
    increment_offset: 45 # It seems to ensure relevant updates are captured from each source, increment settings would need to reflect the maximum required increment from all different sources.  If that proves too inneficient/costly, we can likely replicate the incremental build with sql_create or create_process (https://cloud.google.com/looker/docs/reference/param-view-create-process)

    # End user queries against this table (of which there may be many, unlike tables built in step 2) the will be hitting this table and will benefit from filters appled on partitioned or clustered fields
    partition_keys: ["date_date"]
    cluster_keys: ["user_country"]
  }

###
# Expose the data elements we have made available in the bended dataset.
  dimension: date_date {
    group_label: "Dates"
    type:date
  }
  dimension: date_month {
    group_label: "Dates"
    type:date_month
  }

  dimension: user_country {}
  dimension: order_status {}
  dimension: event_browser {}

  #raw fields that will be re-aggregated into measures
  dimension: order_items_count {hidden:yes}
  dimension: events_count {hidden:yes}
  dimension: total_new_users_count {hidden:yes}

  #measures
  measure: total_order_items_count {type: sum sql: ${order_items_count} ;;}
  measure: total_events_count {type: sum sql: ${events_count} ;;}
  measure: sum_total_new_users_count {type:sum sql:${total_new_users_count};;}

  #demo ratio between fields from different explores.
  measure: items_per_event {
    type: number
    sql: ${total_order_items_count}/nullif(${total_events_count},0) ;;
    value_format_name: decimal_2
    # Note: Not currently in Scope/Focus of this demo, but we expect to develop support for special drill-paths in links or html
    # link: {url:"/explore/events"}
    # html: [custom presentation logic for rendering looker query results, custom drill links, etc] ;;
  }

  dimension: count_distinct_users_hll {hidden:yes} # For clarity and troubleshooting for develoers, recommend defining dimensions for raw columns in blended source table, even those that are helper columns or should only be used as measures (which we'll define separately).  Should hide and should have naming conventions for such cases

  measure: total_count_distinct_users_hll {
    type: number
    sql: hll_count.merge(${count_distinct_users_hll}) ;;
  }
}

###
# Final End user facting explore(s)

explore: blended_data {
  #  persist_with: datagroup-ref # could be used to set cache use policy on this explore - but we have already set at model level

  # aggregate tables can be used to further prepare physical datatables Looker can use to complete end user queries.  When aggregate tables are define in a looker explore, looker will build them, and then try to use them if-and-only-if they can.
  # - Aggregate tables build with similar scheduling to the derived tables.
  # - Generally, aggregate tables must match an exact query you expect to be run later, or must be comprised of only re-aggregateable fields.  They can make queries much faster where applicable, but it is not trivial to decide what tables are worth the maintenece to pre-define this way.
  aggregate_table: date_and_country_only {
    query: {
      dimensions: [date_date,user_country] # some subset of dimensions
      measures: [total_order_items_count] # some subset of measures
    }
    materialization: { # seems materiization would match materialization settings of our blended source table
      datagroup_trigger: marketplace_projects_standard_build_trigger
      increment_key: "date_date"
      increment_offset: 45 #
      partition_keys: ["date_date"]
      cluster_keys: ["user_country"]
    }
  }
}
