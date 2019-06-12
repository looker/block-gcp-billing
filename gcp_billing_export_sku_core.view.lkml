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
