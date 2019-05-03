project_name: "block-gcp-billing"

constant: CONNECTION_NAME {
  value: "gcp_logging"
}

constant: BILLING_EXPORT_TABLE {
  value: "gcp_billing_export_v1_002831_A42942_C36931"
}

# unsure if the out-of-the-box schema is named "gcp_logs", using constant for now
constant: BILLING_EXPORT_SCHEMA {
  value: "gcp_logs"
}
