view: gcp_billing_export_usage {

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
