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

#   ### BELOW Arbitrary Period Comparison Analytical Pattern https://discourse.looker.com/t/arbitrary-period-comparisons/8019
#
#   filter: first_period_selector {
#     group_label: "Arbitrary Period Comparisons"
#     description: "Set date range to compare to 'Second Period Selector'"
#     type: date
#   }
#
#   filter: second_period_selector {
#     group_label: "Arbitrary Period Comparisons"
#     description: "Set date range to compare to 'First Period Selector'"
#     type: date
#   }
#
#   dimension: days_from_start_first {
#     hidden:  yes
#     type:  number
#     sql:  DATE_DIFF(${usage_start_date}, CAST({% date_start first_period_selector %} AS DATE), DAY) ;;
#   }
#
#   dimension: days_from_start_second {
#     hidden:  yes
#     type:  number
#     sql:  DATE_DIFF(${usage_start_date}, CAST({% date_start second_period_selector %} AS DATE), DAY) ;;
#   }
#
#   dimension: days_from_first_period {
#     type: number
#     sql: CASE
#             WHEN ${days_from_start_first} >= 0
#             THEN ${days_from_start_first}
#             WHEN ${days_from_start_second} >=0
#             THEN ${days_from_start_second}
#             END
#             ;;
#   }
#
#   dimension: period_selected {
#     group_label: "Arbitrary Period Comparisons"
#     description: "Pivot by this dimension to see First vs Second Period Series"
#     type:  string
#     sql:  CASE
#             WHEN ${usage_start_raw} >= {% date_start first_period_selector %}
#             AND ${usage_start_raw} <= {% date_end first_period_selector %}
#             THEN 'First Period'
#             WHEN ${usage_start_raw} >= {% date_start second_period_selector %}
#             AND ${usage_start_raw} <= {% date_end second_period_selector %}
#             THEN 'Second Period'
#             END;;
#   }
#
#   ### ABOVE Arbitrary Period Comparison Analytical Pattern https://discourse.looker.com/t/arbitrary-period-comparisons/8019

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


  dimension: is_last_month {
    type: yesno
    sql: ${usage_start_month_num} = EXTRACT(month from CURRENT_TIMESTAMP())-1
          AND ${usage_start_year} = EXTRACT(year from CURRENT_TIMESTAMP());;
  }

  dimension: billing_date {
    type: string
    label_from_parameter: date_view
    sql: EXTRACT({% parameter date_view %} from ${usage_start_raw}) ;;
  }

  dimension: billing_account_id {
    type: string
    sql: ${TABLE}.billing_account_id ;;
  }

  dimension: cost {
    description: "The cost associated to an SKU, between Start Date and End Date"
    type: number
    sql: ${TABLE}.cost ;;
  }

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

  dimension: credits {
    hidden: yes
    sql: ${TABLE}.credits ;;
  }

  measure: t_cost_hide { #used for NDTs, to avoid circular references in inter-dashboard links
    hidden: yes
    type: number
    sql: ${cost_before_credits} + ${gcp_billing_export_credits.total_credit} ;;
    value_format_name: decimal_2
  }

  measure: total_cost {
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
        label: "Project Breakdown"
        url: "/dashboards/block_gcp_billing::billing_by_project?Project={{ project_name_sort.top_10_projects._value | url_encode }}&Time Period=1 months"
      }
  }

  dimension: currency {
    description: "The currency the cost was billed in"
    type: string
    sql: ${TABLE}.currency ;;
  }

  dimension: currency_conversion_rate {
    type: number
    sql: ${TABLE}.currency_conversion_rate ;;
  }

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

  dimension: labels {
    hidden: yes
    sql: ${TABLE}.labels ;;
  }

  dimension: pk {
    type: string
    primary_key: yes
    hidden: yes
    # sql: CONCAT(${billing_account_id},CAST(${usage_start_raw} as STRING),${gcp_billing_export_service.id}, ${gcp_billing_export_sku.id}) ;;
    sql: ${TABLE}.pk ;;
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

  dimension: project {
    hidden: yes
    sql: ${TABLE}.project ;;
  }

  dimension: service {
    hidden: yes
    sql: ${TABLE}.service ;;
  }

  dimension: sku {
    hidden: yes
    sql: ${TABLE}.sku ;;
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

  dimension: usage {
    hidden: yes
    sql: ${TABLE}.usage ;;
  }

  measure: total_usage {
    description: "The units of Usage is the dimension 'Resource', please use the two together"
    type: sum
    sql: ${gcp_billing_export_usage.usage} ;;
  }

}

view: gcp_billing_export_credits_core {
  dimension: credit_amount {
    group_label: "Credits"
    description: "The amount of credit given to account"
    type: number
    sql: ${TABLE}.amount ;;
  }

  dimension: credit_name {
    group_label: "Credits"
    description: "Name of the credit applied to account"
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: credit_id {
    primary_key: yes
#     hidden: yes
    sql: CONCAT(CAST(${gcp_billing_export.pk} as STRING), COALESCE(${credit_name}, "0")) ;;
  }

  measure: total_credit {
    description: "The total credit given to the billing account (always negative)"
    type: sum
    sql: ${credit_amount} ;;
    value_format_name: decimal_2
    html: {% if gcp_billing_export.currency._value == 'GBP' %}
            <a href="{{ link }}"> £{{ rendered_value }}</a>
          {% elsif gcp_billing_export.currency == 'USD' %}
            <a href="{{ link }}"> ${{ rendered_value }}</a>
          {% elsif gcp_billing_export.currency == 'EUR' %}
            <a href="{{ link }}"> €{{ rendered_value }}</a>
          {% else %}
            <a href="{{ link }}"> {{ rendered_value }} {{ gcp_billing_export.currency._value }}</a>
          {% endif %} ;;
    drill_fields: [gcp_billing_export_credits.credit_name,gcp_billing_export_credits.credit_amount]
  }


}

view: gcp_billing_export_labels_core {
  dimension: label_key {
    group_label: "Labels"
    type: string
    sql: ${TABLE}.key ;;
  }

  dimension: label_value {
    group_label: "Labels"
    type: string
    sql: ${TABLE}.value ;;
  }

  dimension: label_id {
    primary_key: yes
    hidden: yes
    sql: CONCAT(CAST(${gcp_billing_export.pk} as STRING), ${label_key}, ${label_value}) ;;
  }
}

view: gcp_billing_export_project_core {
  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: labels {
    hidden: yes
    sql: ${TABLE}.labels ;;
  }

  dimension: name {
    label: "Project Name"
    type: string
    sql: ${TABLE}.name;;
    drill_fields: [gcp_billing_export_service.description, gcp_billing_export.sku_category, gcp_billing_export_sku.description]
  }

  measure: name_filter { #Made for single value visualization
    type: string
    sql: {% if name._is_filtered %}
        STRING_AGG(DISTINCT ${name}, ", ")
       {% else %}
        ANY_VALUE("All Projects")
       {% endif %};;
  }

### test for one-vs-many project tiles

  filter: project_comparison {
    type: string
  }

  dimension: project_compare  {
    type: yesno
    sql: {% condition project_comparison %} ${name} {% endcondition %} ;;
  }

  ## end test
}

view: gcp_billing_export_service_core {
  dimension: id {
    hidden: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: description {
    label: "Service"
    type: string
    sql: ${TABLE}.description ;;
    drill_fields: [gcp_billing_export_project.name, gcp_billing_export.sku_category, gcp_billing_export_sku.description]
  }
}

view: gcp_billing_export_sku_core {
  dimension: id {
    hidden: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: description {
    label: "SKU"
    description: "The most granular level of detail"
    type: string
    sql: ${TABLE}.description ;;
  }
}

view: gcp_billing_export_usage_core {
  dimension: usage {
    group_label: "Resource Usage"
    type: number
    sql: ${TABLE}.amount ;;
  }

  dimension: unit {
    group_label: "Resource Usage"
    label: "Resource"
    type: string
    sql: ${TABLE}.unit ;;
  }
}

################## SORT DERIVED TABLES USED FOR STACKED VIZ'S ##################

view: project_name_sort_core {
  derived_table: {
    explore_source: gcp_billing_export {
      column: name { field: gcp_billing_export_project.name }
      column: t_cost_hide {}
      derived_column: rank {
        sql: RANK() OVER (ORDER BY COALESCE(t_cost_hide, 0) DESC) ;;
      }

      bind_filters: {
        to_field: gcp_billing_export.date_filter
        from_field: gcp_billing_export.date_filter
      }
      bind_filters: {
        to_field: gcp_billing_export.usage_start_date
        from_field: gcp_billing_export.usage_start_date
      }
      bind_filters: {
        to_field: gcp_billing_export_project.name
        from_field: gcp_billing_export_project.name
      }
      bind_filters: {
        to_field: gcp_billing_export_service.description
        from_field: gcp_billing_export_service.description
      }
    }
  }
  dimension: name {
    label: "Project Name"
    primary_key: yes
    hidden: yes
  }
  dimension: top_10_projects {
    description: "If a project is within the Top 10 based in total cost, then its individual name appears in the dimension output. Otherwise, it's bucketed into the 'Other' section."
    sql:  CASE WHEN ${rank} <= 10 THEN ${name}
               ELSE 'Other'
               END;;
    hidden: no
    order_by_field: rank_10
  }
  dimension: t_cost_hide {
    label: "Total Cost"
    description: "The total cost associated to the SKU, between the Start Date and End Date"
    value_format: "#,##0.00"
    type: number
    hidden: yes
  }

  dimension: rank {
    type: number
    hidden: yes
  }

  dimension: rank_10 {
    type:  number
    hidden:  yes
    sql:  CASE WHEN ${rank} <= 10 THEN ${rank}
          ELSE 11
          END ;;
  }
}

view: service_name_sort_core {
  derived_table: {
    explore_source: gcp_billing_export {
      column: name { field: gcp_billing_export_service.description }
      column: t_cost_hide {}
      derived_column: rank {
        sql: RANK() OVER (ORDER BY COALESCE(t_cost_hide, 0) DESC) ;;
      }

      bind_filters: {
        to_field: gcp_billing_export.date_filter
        from_field: gcp_billing_export.date_filter
      }
      bind_filters: {
        to_field: gcp_billing_export.usage_start_date
        from_field: gcp_billing_export.usage_start_date
      }
      bind_filters: {
        to_field: gcp_billing_export_project.name
        from_field: gcp_billing_export_project.name
      }
      bind_filters: {
        to_field: gcp_billing_export_service.description
        from_field: gcp_billing_export_service.description
      }
    }
  }

  dimension: name {
    label: "Service Name"
    primary_key: yes
    hidden: yes
  }
  dimension: top_10_services {
    description: "If a service is within the Top 10 based in total cost, then its individual name appears in the dimension output. Otherwise, it's bucketed into the 'Other' section."
    sql:  CASE WHEN ${rank} <= 10 THEN ${name}
               ELSE 'Other'
               END;;
    hidden: no
    order_by_field: rank_10
  }
  dimension: t_cost_hide {
    label: "Total Cost"
    description: "The total cost associated to the SKU, between the Start Date and End Date"
    value_format: "#,##0.00"
    type: number
    hidden: yes
  }
  dimension: rank {
    type: number
    hidden: yes
  }

  dimension: rank_10 {
    type:  number
    hidden:  yes
    sql:  CASE WHEN ${rank} <= 10 THEN ${rank}
    ELSE 11
    END ;;
  }
}
