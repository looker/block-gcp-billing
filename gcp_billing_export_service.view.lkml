view: gcp_billing_export_service {
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
