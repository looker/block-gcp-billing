view: gcp_billing_export_sku {

  ### Field description reference https://cloud.google.com/billing/docs/how-to/export-data-bigquery
### DIMENSIONS

  dimension: id {
    description: "The ID of the resource used by the service."
    hidden: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: description {
    label: "SKU"
    description: "A description of the resource type used by the service. The most granular level of detail."
    type: string
    sql: ${TABLE}.description ;;
  }
}
