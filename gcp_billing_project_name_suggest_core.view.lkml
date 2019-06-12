view: project_name_suggest_core {
  derived_table: {
    sql: SELECT
        *
      FROM
        @{SCHEMA_NAME}.@{BILLING_EXPORT_TABLE_NAME}
      WHERE
      CAST(_PARTITIONTIME AS DATE) BETWEEN DATE_ADD(CURRENT_DATE(), INTERVAL -6 Month) AND CURRENT_DATE()
 ;;
  }

  measure: count {
    hidden: yes
    type: count
    drill_fields: [detail*]
  }

  dimension: project_name_suggestion {
    hidden: yes
    type: string
    sql: ${TABLE}.gcp_billing_export_project_name ;;
  }

  set: detail {
    fields: [project_name_suggestion]
  }
}
