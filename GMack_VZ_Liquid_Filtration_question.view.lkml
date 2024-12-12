include: "//thelook_ecommerce_autogen_files/auto_gen_views/order_items.view.lkml"
view: gmack_vz_liquid_filtration_question {
  extends: [order_items]
  dimension_group: activity_dt {
    type: time
    timeframes: [raw,date,month,month_name,week]
    sql: ${created_at_raw} ;;
  }
###
  parameter: date_granularity {
    type: unquoted
    view_label: "Dates"
    allowed_value: {
      label: "Break down by Month"
      value: "month"
    }
    allowed_value: {
      label: "Break down by Month Name"
      value: "month_name"
    }
    allowed_value: {
      label: "Break down by Week"
      value: "week"
    }
    allowed_value: {
      label: "Break down by Day"
      value: "day"
    }
  }

  dimension: date_switch {
    view_label: "Dates"
    sql:
      {% if date_granularity._parameter_value == 'day' %}
        ${activity_dt_date}
      {% elsif date_granularity._parameter_value == 'month' %}
        ${activity_dt_month}
      {% elsif date_granularity._parameter_value == 'month_name' %}
        ${activity_dt_month_name}
      {% elsif date_granularity._parameter_value == 'week' %}
        ${activity_dt_week}
      {% else %}
        ${activity_dt_date}
      {% endif %}
    ;;
  }

  dimension: meets_default_filter_for_date_switch {
    type: yesno
    sql:
    --date_granularity._parameter_value: {{date_granularity._parameter_value}}
      {% if date_granularity._parameter_value == 'day' %}
             ${activity_dt_raw} >= ((TIMESTAMP_ADD(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY, 'UTC'), INTERVAL -13 DAY)))
        AND (${activity_dt_raw} < ((TIMESTAMP_ADD(TIMESTAMP_ADD(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY, 'UTC'), INTERVAL -13 DAY), INTERVAL 14 DAY))))
      {% elsif date_granularity._parameter_value == 'month' %}
            ((  ${activity_dt_raw} >= ((TIMESTAMP(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY, 'UTC'), MONTH)), INTERVAL -23 MONTH))))
            AND ${activity_dt_raw} < ((TIMESTAMP(DATETIME_ADD(DATETIME(TIMESTAMP(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY, 'UTC'), MONTH)), INTERVAL -23 MONTH))), INTERVAL 24 MONTH))))))
      {% elsif date_granularity._parameter_value == 'month_name' %}
            ((  ${activity_dt_raw} >= ((TIMESTAMP(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY, 'UTC'), MONTH)), INTERVAL -23 MONTH))))
            AND ${activity_dt_raw} < ((TIMESTAMP(DATETIME_ADD(DATETIME(TIMESTAMP(DATETIME_ADD(DATETIME(TIMESTAMP_TRUNC(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY, 'UTC'), MONTH)), INTERVAL -23 MONTH))), INTERVAL 24 MONTH))))))
      {% elsif date_granularity._parameter_value == 'week' %}
        ((    ${activity_dt_raw} >= ((TIMESTAMP_ADD(TIMESTAMP_TRUNC(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY, 'UTC'), WEEK(MONDAY)), INTERVAL (-11 * 7) DAY)))
          AND ${activity_dt_raw} < ((TIMESTAMP_ADD(TIMESTAMP_ADD(TIMESTAMP_TRUNC(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY, 'UTC'), WEEK(MONDAY)), INTERVAL (-11 * 7) DAY), INTERVAL (12 * 7) DAY)))))
      {% else %}
      --else case, used same logic as day
             ${activity_dt_raw} >= ((TIMESTAMP_ADD(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY, 'UTC'), INTERVAL -13 DAY)))
        AND (${activity_dt_raw} < ((TIMESTAMP_ADD(TIMESTAMP_ADD(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY, 'UTC'), INTERVAL -13 DAY), INTERVAL 14 DAY))))
      {% endif %}

    ;;
  }

}
