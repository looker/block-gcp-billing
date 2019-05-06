view: gcp_billing_export_credits {
  dimension: credit_amount {
    group_label: "Credits"
    description: "The amount of credit given to account"
    type: number
    sql: ${TABLE}.amount ;;
  }

  dimension: credit_name {
    group_label: "Credits"
    description: "Nmae of the credit applied to account"
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: credit_id {
    primary_key: yes
#     hidden: yes
    sql: CONCAT(CAST(${gcp_billing_export.pk} as STRING), ${credit_name}) ;;
  }
}
