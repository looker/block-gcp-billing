project_name: "block-gcp-billing"

################ Constants ################

constant: CONNECTION_NAME {
  value: "gcp_logging"
  export: override_optional
}

constant: SCHEMA_NAME {
  value: "gcp_logs"
  export: override_optional
}

# Looks like it should just be a single table, so no _* notation
constant: BILLING_EXPORT_TABLE_NAME {
  value: "gcp_billing_export_v1_002831_A42942_C36931"
  export: override_optional
}
