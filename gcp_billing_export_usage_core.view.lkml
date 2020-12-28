include: "//@{CONFIG_PROJECT_NAME}/gcp_billing_export.view"

view: gcp_billing_export_usage {
  extends: [gcp_billing_export_usage_config]
}


view: gcp_billing_export_usage_core {

  ### Field description reference https://cloud.google.com/billing/docs/how-to/export-data-bigquery
### DIMENSIONS

  dimension: usage {
    group_label: "Resource Usage"
    description: "The quantity of usage units used"
    type: number
    sql: ${TABLE}.amount ;;
  }

  dimension: unit {
    group_label: "Resource Usage"
    label: "Resource"
    description: "The base unit in which resource usage is measured."
    type: string
    sql: ${TABLE}.unit ;;
  }
}
