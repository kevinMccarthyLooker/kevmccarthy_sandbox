view: bq_information_schema_columns__autoLookML {
  derived_table: {
    sql: select * from `region-us`.INFORMATION_SCHEMA.COLUMNS;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: table_catalog {}
  dimension: table_schema {}
  dimension: table_name {}
  dimension: column_name {}
  dimension: ordinal_position {}
  dimension: is_nullable {}
  dimension: data_type {}
  dimension: is_generated {}
  dimension: generation_expression {}
  dimension: is_stored {}
  dimension: is_hidden {}
  dimension: is_updatable {}
  dimension: is_system_defined {}
  dimension: is_partitioning_column {}
  dimension: clustering_ordinal_position {}
  dimension: collation_name {}
  dimension: column_default {}
  dimension: rounding_mode {}

  set: detail { fields: [table_catalog, table_schema, table_name, column_name, ordinal_position, is_nullable, data_type, is_generated, generation_expression, is_stored, is_hidden, is_updatable, is_system_defined, is_partitioning_column, clustering_ordinal_position, collation_name, column_default, rounding_mode] }
}

view: bq_information_schema_columns {
  extends: [bq_information_schema_columns__autoLookML]
  derived_table: {
    sql:
    {% assign original_sql = '${EXTENDED}' %}
    {% assign region_parameter_value = region._parameter_value |replace: "'",""%}
    {% assign updated_sql = original_sql |replace: '`region-us`', region_parameter_value %}
    {{updated_sql}}
    ;;
  }
  parameter: region {
    allowed_value: {value:"`us-east5`"}
    allowed_value: {value:"`us-south1`"}
    allowed_value: {value:"`us-central1`"}
    allowed_value: {value:"`us-west4`"}
    allowed_value: {value:"`us-west2`"}
    allowed_value: {value:"`northamerica-northeast1`"}
    allowed_value: {value:"`us-east4`"}
    allowed_value: {value:"`us-west1`"}
    allowed_value: {value:"`us-west3`"}
    allowed_value: {value:"`southamerica-east1`"}
    allowed_value: {value:"`southamerica-west1`"}
    allowed_value: {value:"`us-east1`"}
    allowed_value: {value:"`northamerica-northeast2`"}

    allowed_value: {value:"`asia-south2`"}
    allowed_value: {value:"`asia-east2`"}
    allowed_value: {value:"`asia-southeast2`"}
    allowed_value: {value:"`australia-southeast2`"}
    allowed_value: {value:"`asia-south1`"}
    allowed_value: {value:"`asia-northeast2`"}
    allowed_value: {value:"`asia-northeast3`"}
    allowed_value: {value:"`asia-southeast1`"}
    allowed_value: {value:"`australia-southeast1`"}
    allowed_value: {value:"`asia-east1`"}
    allowed_value: {value:"`asia-northeast1`"}

    allowed_value: {value:"`europe-west1`"}
    allowed_value: {value:"`europe-west10`"}
    allowed_value: {value:"`europe-north1`"}
    allowed_value: {value:"`europe-west3`"}
    allowed_value: {value:"`europe-west2`"}
    allowed_value: {value:"`europe-southwest1`"}
    allowed_value: {value:"`europe-west8`"}
    allowed_value: {value:"`europe-west4`"}
    allowed_value: {value:"`europe-west9`"}
    allowed_value: {value:"`europe-west12`"}
    allowed_value: {value:"`europe-central2`"}
    allowed_value: {value:"`europe-west6`"}

    allowed_value: {value:"`me-central2`"}
    allowed_value: {value:"`me-central1`"}
    allowed_value: {value:"`me-west1`"}

    allowed_value: {value:"`africa-south1`"}

    allowed_value: {value:"`region-us`"}
    allowed_value: {value:"`region-eu`"}

    default_value: "`region-us`"
  }

  measure: count {
    hidden: yes
  }

  dimension: pk {
    view_label: "tech support fields"
    primary_key: yes
    sql: concat(${table_catalog},${table_schema},${table_name},${column_name}) ;;
  }

  measure: column_count {
    # Counts distinct columns across all tables by using the concatenated primary key, excluding NULL values
    type: count 
    filters: [pk: "-NULL"]
  }

  # Set up drill-down path from catalog -> schema -> table -> column
  dimension: table_catalog {drill_fields:[table_schema]}
  dimension: table_schema {drill_fields:[table_name]}
  dimension: table_name {drill_fields:[column_name]}

  dimension: ordinal_position {
    hidden: yes
  }

}

#refinements
view: +bq_information_schema_columns {
#adding Descriptions from docs page: https://cloud.google.com/bigquery/docs/information-schema-columns
  dimension: table_catalog{description:"The project ID of the project that contains the dataset"}
  dimension: table_schema{description:"The name of the dataset that contains the table also referred to as the datasetId"}
  dimension: table_name{description:"The name of the table or view also referred to as the tableId"}
  dimension: column_name{description:"The name of the column"}
  dimension: ordinal_position{description:"The 1-indexed offset of the column within the table; if it's a pseudo column such as _PARTITIONTIME or _PARTITIONDATE, the value is NULL"}
  dimension: is_nullable{description:"YES or NO depending on whether the column's mode allows NULL values"}
  dimension: data_type{description:"The column's GoogleSQL data type"}
  dimension: is_generated{description:"The value is always NEVER"}
  dimension: generation_expression{description:"The value is always NULL"}
  dimension: is_stored{description:"The value is always NULL"}
  dimension: is_hidden{description:"YES or NO depending on whether the column is a pseudo column such as _PARTITIONTIME or _PARTITIONDATE"}
  dimension: is_updatable{description:"The value is always NULL"}
  dimension: is_system_defined{description:"YES or NO depending on whether the column is a pseudo column such as _PARTITIONTIME or _PARTITIONDATE"}
  dimension: is_partitioning_column{description:"YES or NO depending on whether the column is a partitioning column"}
  dimension: clustering_ordinal_position{description:"The 1-indexed offset of the column within the table's clustering columns; the value is NULL if the table is not a clustered table"}
  dimension: collation_name{description:"The name of the collation specification if it exists; otherwise, NULL.  If a STRING or ARRAY<STRING> is passed in, the collation specification is returned if it exists; otherwise NULL is returned"}
  dimension: column_default{description:"The default value of the column if it exists; otherwise, the value is NULL"}
  dimension: rounding_mode{description:"The mode of rounding that's used for values written to the field if its type is a parameterized NUMERIC or BIGNUMERIC; otherwise, the value is NULL"}

#fields that never have useful info (2024-11-20). https://cloud.google.com/bigquery/docs/information-schema-columns
  dimension: is_generated{hidden: yes}
  dimension: generation_expression{hidden: yes}
  dimension: is_stored{hidden: yes}
  dimension: is_updatable{hidden: yes}
}
