view: gcp_billing_export_project_core {
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

  measure: name_filter { #Made for single value visualization
    type: string
    sql: {% if name._is_filtered %}
        STRING_AGG(DISTINCT ${name}, ", ")
       {% else %}
        ANY_VALUE("All Projects")
       {% endif %};;
  }

### For one-vs-many project tiles on billing_by_project dashboard

  filter: project_comparison {
    type: string
  }

  dimension: project_compare  {
    type: yesno
    sql: {% condition project_comparison %} ${name} {% endcondition %} ;;
  }
}
