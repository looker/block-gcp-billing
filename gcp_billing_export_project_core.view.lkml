include: "//@{CONFIG_PROJECT_NAME}/gcp_billing_export.view"

view: gcp_billing_export_project {
  extends: [gcp_billing_export_project_config]
}


view: gcp_billing_export_project_core {

  ### Field description reference https://cloud.google.com/billing/docs/how-to/export-data-bigquery
### DIMENSIONS

  dimension: id {
    description: "The ID of the project that generated the billing data."
    primary_key: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: labels { # For use only if labels are present https://cloud.google.com/resource-manager/docs/using-labels
    hidden: yes
    sql: ${TABLE}.labels ;;
  }

  dimension: name {
    label: "Project Name"
    description: "The name of the project that generated the billing data."
    type: string
    full_suggestions: yes
    sql: ${TABLE}.name;;
    drill_fields: [gcp_billing_export_service.description, gcp_billing_export.sku_category, gcp_billing_export_sku.description]
  }

### For one-vs-many project tiles on billing_by_project dashboard

  filter: project_comparison {
    type: string
  }

  dimension: project_compare  {
    type: yesno
    sql: {% condition project_comparison %} ${name} {% endcondition %} ;;
  }

### MEASURES

  measure: name_filter { #Made for single value visualization
    type: string
    sql: {% if name._is_filtered %}
         STRING_AGG(DISTINCT ${name}, ", ")
         {% else %}
         ANY_VALUE("All Projects")
         {% endif %};;
  }
}
