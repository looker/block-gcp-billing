view: gcp_billing_export_usage {
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
