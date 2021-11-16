view: project_name_sort {

  ### NDT created to achieve ordering in visualization based on total cost

  derived_table: {
    explore_source: gcp_billing_export {
      column: name { field: gcp_billing_export_project.name }
      column: total_cost {}
      derived_column: rank {
        sql: RANK() OVER (ORDER BY COALESCE(total_cost, 0) DESC) ;;
      }

      bind_filters: {
        to_field: gcp_billing_export.date_filter
        from_field: gcp_billing_export.date_filter
      }
      bind_filters: {
        to_field: gcp_billing_export.usage_start_date
        from_field: gcp_billing_export.usage_start_date
      }
      bind_filters: {
        to_field: gcp_billing_export_project.name
        from_field: gcp_billing_export_project.name
      }
      bind_filters: {
        to_field: gcp_billing_export_service.description
        from_field: gcp_billing_export_service.description
      }
    }
  }

### DIMENSIONS

  dimension: name {
    label: "Project Name"
    primary_key: yes
    hidden: yes
  }

  dimension: top_10_projects {
    description: "If a project is within the Top 10 based in total cost, then its individual name appears in the dimension output. Otherwise, it's bucketed into the 'Other' section."
    sql:  CASE WHEN ${rank} <= 10 THEN ${name}
               ELSE 'Other'
               END;;
    hidden: no
    order_by_field: rank_10
  }

  dimension: rank_10 { # Provides numeric sorting (10 after 9) for top_10_projects instead of default string sorting (10 before 2)
    type:  number
    hidden:  yes
    sql:  CASE WHEN ${rank} <= 10 THEN ${rank}
          ELSE 11
          END ;;
  }

  dimension: total_cost { # Dimensionalized version of the measure "Total Cost"
    label: "Total Cost"
    description: "The total cost associated to the SKU, between the Start Date and End Date"
    value_format: "#,##0.00"
    type: number
    hidden: yes
  }

  dimension: rank { # Ranks projects by Total Cost
    type: number
    hidden: yes
  }
}
