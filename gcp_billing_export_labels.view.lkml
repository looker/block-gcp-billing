view: gcp_billing_export_labels {
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
