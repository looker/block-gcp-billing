include: "//@{CONFIG_PROJECT_NAME}/gcp_billing_export.view"

view: gcp_billing_export_sku {
  extends: [gcp_billing_export_sku_config]
}


view: gcp_billing_export_sku_core {

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
