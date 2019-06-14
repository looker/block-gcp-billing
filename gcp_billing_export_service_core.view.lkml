view: gcp_billing_export_service_core {

  ### Field description reference https://cloud.google.com/billing/docs/how-to/export-data-bigquery
### DIMENSIONS

  dimension: id {
    description: "The ID of the service that the usage is associated with."
    hidden: yes
    type: string
    sql: ${TABLE}.id ;;
  }

  dimension: description {
    label: "Service"
    description: "The Google Cloud Platform service that reported the billing data."
    type: string
    sql: ${TABLE}.description ;;
    drill_fields: [gcp_billing_export_project.name, gcp_billing_export.sku_category, gcp_billing_export_sku.description]
  }

### For one-vs-many project tiles on billing_by_project dashboard

  filter: service_comparison {
    type: string
  }

  dimension: service_compare  {
    type: yesno
    sql: {% condition service_comparison %} ${description} {% endcondition %} ;;
  }

### MEASURES

  measure: service_filter { #Made for single value visualization
    type: string
    sql: {% if description._is_filtered %}
         STRING_AGG(DISTINCT ${description}, ", ")
         {% else %}
         ANY_VALUE("All Services")
         {% endif %};;
  }
}
