include: "//@{CONFIG_PROJECT_NAME}/gcp_billing_export.view"

view: gcp_billing_export {
  extends: [gcp_billing_export_config]
}

view: gcp_billing_export_core {
  derived_table: {
    sql:
      SELECT
        *,
        GENERATE_UUID() as pk
      FROM
        @{SCHEMA_NAME}.@{BILLING_EXPORT_TABLE_NAME}
      WHERE
        {% condition date_filter %} _PARTITIONTIME {% endcondition %} ;;
  }

  ### FILTER ONLY FIELDS

  filter: date_filter {
    type: date
  }

  parameter: date_view {
    type: unquoted
    default_value: "Day"
    allowed_value: {
      label: "Year"
      value: "YEAR"
    }
    allowed_value: {
      label: "Month"
      value: "MONTH"
    }
    allowed_value: {
      label: "Day"
      value: "DATE"
    }
  }

  ### Field description reference https://cloud.google.com/billing/docs/how-to/export-data-bigquery
  ### DIMENSIONS

  dimension: pk {
    type: string
    primary_key: yes
    hidden: yes
    # sql: CONCAT(${billing_account_id},CAST(${usage_start_raw} as STRING),${gcp_billing_export_service.id}, ${gcp_billing_export_sku.id}) ;;
    sql: ${TABLE}.pk ;;
  }

  dimension: is_last_month {
    type: yesno
    sql: ${usage_start_month_num} = EXTRACT(month from CURRENT_TIMESTAMP())-1
          AND ${usage_start_year} = EXTRACT(year from CURRENT_TIMESTAMP());;
  }

  dimension: billing_date {
    description: "Use with filter only field 'Date View' to alter granularity"
    type: string
    label_from_parameter: date_view
    sql: EXTRACT({% parameter date_view %} from ${usage_start_raw}) ;;
  }

  dimension: billing_account_id {
    description: "The billing account ID that the usage is associated with."
    type: string
    sql: ${TABLE}.billing_account_id ;;
  }

  dimension: cost {
    description: "The cost associated to an SKU, between Start Date and End Date"
    type: number
    sql: ${TABLE}.cost ;;
  }

  dimension: credits { # Nested record
    hidden: yes
    sql: ${TABLE}.credits ;;
  }

  dimension: currency {
    description: "The currency the cost was billed in"
    type: string
    sql: ${TABLE}.currency ;;
  }

  dimension: currency_conversion_rate {
    description: "The exchange rate from US dollars to the local currency. That is, cost/currency_conversion_rate is the cost in US dollars."
    type: number
    sql: ${TABLE}.currency_conversion_rate ;;
  }

  dimension: labels { # Nested record
    hidden: yes
    sql: ${TABLE}.labels ;;
  }

  dimension: sku_category {
    type: string
    description: "Provides an additional layer of granularity above SKU"
    drill_fields: [gcp_billing_export_sku.description]
    sql:
      CASE
        WHEN (${gcp_billing_export_service.description} = "Compute Engine"
              AND ${gcp_billing_export_sku.description} LIKE '%Licensing%') THEN 'Compute Engine License'
        WHEN (${gcp_billing_export_service.description} = "Compute Engine"
              AND ${gcp_billing_export_sku.description} LIKE '%Network%') THEN 'Networking'
        WHEN (${gcp_billing_export_service.description} = "Compute Engine"
              AND (${gcp_billing_export_sku.description} LIKE '%instance%'
                  or ${gcp_billing_export_sku.description} LIKE '%Instance%')) THEN 'Compute Engine Instance'
        WHEN (${gcp_billing_export_service.description} = "Compute Engine"
              AND ${gcp_billing_export_sku.description} LIKE '%PD%') THEN 'Compute Engine Storage'
        WHEN (${gcp_billing_export_service.description} = "Compute Engine"
              AND ${gcp_billing_export_sku.description} LIKE '%Intel%') THEN 'Compute Engine Instance'
        WHEN (${gcp_billing_export_service.description} = "Compute Engine"
              AND ${gcp_billing_export_sku.description} LIKE '%Storage%') THEN 'Compute Engine Storage'
        WHEN (${gcp_billing_export_service.description} = "Compute Engine"
              AND ${gcp_billing_export_sku.description} LIKE '%Ip%') THEN 'Networking'
        WHEN (${gcp_billing_export_service.description} = "BigQuery"
              AND ${gcp_billing_export_sku.description} LIKE '%Storage%') THEN 'BigQuery Storage'
        WHEN (${gcp_billing_export_service.description} = "BigQuery"
              AND ${gcp_billing_export_sku.description} = "Analysis") THEN 'BigQuery Analysis'
        WHEN (${gcp_billing_export_service.description} = "BigQuery"
              AND ${gcp_billing_export_sku.description} = 'Streaming Insert') THEN 'BigQuery Streaming'
        WHEN (${gcp_billing_export_service.description} = 'Cloud Storage'
              AND ${gcp_billing_export_sku.description} LIKE '%Storage%') THEN 'GCS Storage'
        WHEN (${gcp_billing_export_service.description} = 'Cloud Storage'
              AND ${gcp_billing_export_sku.description} LIKE '%Download%') THEN 'GCS Download'
        WHEN (${gcp_billing_export_service.description} = 'Cloud Dataflow'
              AND ${gcp_billing_export_sku.description} LIKE '%PD%') THEN 'Dataflow PD'
        WHEN (${gcp_billing_export_service.description} = 'Cloud Dataflow'
              AND (${gcp_billing_export_sku.description} LIKE '%vCPU%'
                    OR ${gcp_billing_export_sku.description} LIKE '%RAM%')) THEN 'Dataflow Compute'
        ELSE ${gcp_billing_export_service.description}
      END  ;;
  }

  dimension: project { # Nested record
    hidden: yes
    sql: ${TABLE}.project ;;
  }

  dimension: service { # Nested record
    hidden: yes
    sql: ${TABLE}.service ;;
  }

  dimension: sku { # Nested record
    hidden: yes
    sql: ${TABLE}.sku ;;
  }

  dimension: usage { # Nested record
    hidden: yes
    sql: ${TABLE}.usage ;;
  }

  ### DIMENSION GROUPS

  dimension_group: export {
    description: "Time at which the billing was exported"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      month_name,
      month_num,
      week_of_year,
      day_of_month,
      quarter,
      year
    ]
    sql: ${TABLE}.export_time ;;
  }

  dimension_group: usage_end {
    description: "Time at which the cost associated with a SKU ended"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      month_name,
      month_num,
      week_of_year,
      day_of_month,
      quarter,
      year
    ]
    sql: ${TABLE}.usage_end_time ;;
  }

  dimension_group: usage_start {
    description: "Time at which the cost associated with a SKU started"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      month_name,
      month_num,
      week_of_year,
      day_of_month,
      quarter,
      year
    ]
    sql: ${TABLE}.usage_start_time ;;
  }

  ### MEASURES

  measure: cost_before_credits {
    description: "The cost associated to an SKU before any credits, between the Start Date and End Date"
    type: sum
    sql: ${TABLE}.cost ;;
    value_format_name: decimal_2
    html: {% if currency._value == 'GBP' %}
            <a href="{{ link }}"> £{{ rendered_value }}</a>
          {% elsif currency == 'USD' %}
            <a href="{{ link }}"> ${{ rendered_value }}</a>
          {% elsif currency == 'EUR' %}
            <a href="{{ link }}"> €{{ rendered_value }}</a>
          {% else %}
            <a href="{{ link }}"> {{ rendered_value }} {{ currency._value }}</a>
          {% endif %} ;;
    drill_fields: [gcp_billing_export_project.name, gcp_billing_export_service.description, sku_category, gcp_billing_export_sku.description, gcp_billing_export_usage.unit, gcp_billing_export_usage.total_usage, total_cost]
  }

  measure: total_usage {
    description: "The units of Usage is the dimension 'Resource', please use the two together"
    type: sum
    sql: ${gcp_billing_export_usage.usage} ;;
    html: {{value}} {{ gcp_billing_export_usage.unit._value }} ;;
  }

  measure: total_cost { # in_query in link specifications to avoid fanout
    description: "The total cost associated to the SKU with credits applied, between the Start Date and End Date"
    type: number
    sql: ${cost_before_credits} + ${gcp_billing_export_credits.total_credit} ;;
    value_format_name: decimal_2
    html: {% if currency._value == 'GBP' %}
            <a href="{{ link }}"> £{{ rendered_value }}</a>
          {% elsif currency == 'USD' %}
            <a href="{{ link }}"> ${{ rendered_value }}</a>
          {% elsif currency == 'EUR' %}
            <a href="{{ link }}"> €{{ rendered_value }}</a>
          {% else %}
            <a href="{{ link }}"> {{ rendered_value }} {{ currency._value }}</a>
          {% endif %} ;;
    drill_fields: [gcp_billing_export_project.name, gcp_billing_export_service.description, sku_category, gcp_billing_export_sku.description, gcp_billing_export_usage.unit, gcp_billing_export_usage.total_usage, total_cost]
    link: {
      label: "{% if project_name_sort.top_10_projects._in_query %}Project Breakdown{% elsif service_name_sort.top_10_services._in_query %}Service Breakdown{% else %}{% endif %}"
      url: "{% if project_name_sort.top_10_projects._in_query %}/dashboards/block_gcp_billing::billing_by_project?Project={{ project_name_sort.top_10_projects._value | url_encode }}&Time Period=1 months{% elsif service_name_sort.top_10_services._in_query %}/dashboards/block_gcp_billing::billing_by_service?Service={{ service_name_sort.top_10_services._value | url_encode }}&Time Period=1 months{% else %}{% endif %}"
    }
  }
}
