view: gcp_billing_export_project {
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
}
