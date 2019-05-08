project_name: "block-gcp-billing"

constant: CONNECTION_NAME {
  value: "gcp_logging"
}

constant: BILLING_EXPORT_SCHEMA_NAME {
  value: "gcp_logs"
}

# May need to add a note making sure to include the "_*" at the end as a wildcard
constant: BILLING_EXPORT_TABLE_NAME {
  value: "gcp_billing_export_v1_002831_A42942_C36931"
}
