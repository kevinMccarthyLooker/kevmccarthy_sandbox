view: iowa_liquor_sales_sales {
  derived_table: {
    sql: select * from `bigquery-public-data.iowa_liquor_sales.sales` limit 10 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: invoice_and_item_number {
    type: string
    sql: ${TABLE}.invoice_and_item_number ;;
  }

  dimension: date {
    type: date
    datatype: date
    sql: ${TABLE}.date ;;
  }

  dimension: store_number {
    type: string
    sql: ${TABLE}.store_number ;;
  }

  dimension: store_name {
    type: string
    sql: ${TABLE}.store_name ;;
  }

  dimension: address {
    type: string
    sql: ${TABLE}.address ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: zip_code {
    type: string
    sql: ${TABLE}.zip_code ;;
  }

  dimension: store_location {
    type: string
    sql: ${TABLE}.store_location ;;
  }

  dimension: county_number {
    type: string
    sql: ${TABLE}.county_number ;;
  }

  dimension: county {
    type: string
    sql: ${TABLE}.county ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: category_name {
    type: string
    sql: ${TABLE}.category_name ;;
  }

  dimension: vendor_number {
    type: string
    sql: ${TABLE}.vendor_number ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}.vendor_name ;;
  }

  dimension: item_number {
    type: string
    sql: ${TABLE}.item_number ;;
  }

  dimension: item_description {
    type: string
    sql: ${TABLE}.item_description ;;
  }

  dimension: pack {
    type: number
    sql: ${TABLE}.pack ;;
  }

  dimension: bottle_volume_ml {
    type: number
    sql: ${TABLE}.bottle_volume_ml ;;
  }

  dimension: state_bottle_cost {
    type: number
    sql: ${TABLE}.state_bottle_cost ;;
  }

  dimension: state_bottle_retail {
    type: number
    sql: ${TABLE}.state_bottle_retail ;;
  }

  dimension: bottles_sold {
    type: number
    sql: ${TABLE}.bottles_sold ;;
  }

  dimension: sale_dollars {
    type: number
    sql: ${TABLE}.sale_dollars ;;
  }

  dimension: volume_sold_liters {
    type: number
    sql: ${TABLE}.volume_sold_liters ;;
  }

  dimension: volume_sold_gallons {
    type: number
    sql: ${TABLE}.volume_sold_gallons ;;
  }

  set: detail {
    fields: [
      invoice_and_item_number,
      date,
      store_number,
      store_name,
      address,
      city,
      zip_code,
      store_location,
      county_number,
      county,
      category,
      category_name,
      vendor_number,
      vendor_name,
      item_number,
      item_description,
      pack,
      bottle_volume_ml,
      state_bottle_cost,
      state_bottle_retail,
      bottles_sold,
      sale_dollars,
      volume_sold_liters,
      volume_sold_gallons
    ]
  }
}
