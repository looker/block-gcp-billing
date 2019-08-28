# GCP Billing and BigQuery Audit

This repository contains a Looker block for analysing **Google Cloud Platform logs**. We provide a Looker model called **GCP Billing** which sits on top of GCP billing log exports. This model allows you to analyse billing data across projects and across services and resource types, allowing you to efficiently manage you GCP Billing account. We also provide projected monthly spend based on your current daily billing, so you can take actions to control spending across your organisation.

## Getting Started

Let's run through the steps in Google Cloud Platform to setup the logging exports and the Looker block.

### GCP Setup

Create a BigQuery dataset for the billing. Go to the Google Cloud Platform console, and select **BigQuery**, or go to https://bigquery.cloud.google.com/. Click the drop down next to the project name and select **Create New Dataset**, set a location and click **OK**.

*Optional:* We recommend setting up a new GCP Project, purely for this purpose.

### Setting up the Billing Export

To setup a billing export to BigQuery do the following:

1. Go to the Google Cloud Platform console and select **Billing**
2. Choose the appropriate billing account (if you have more than one) using **Manage billing accounts**
3. Click **Billing Export** > **BigQuery export**
4. Select the Project and Dataset you created earlier
5. Click **Enable BigQuery export**

Billing data will now be exported to your dataset at regular intervals. The Billing export table is date partitioned, and will incur a small data storage charge.

```
Note: Recently the GCP Billing Export moved from Beta to v1. If you activated the billing export before the change, then there will be two tables in your export dataset. This model sits on top of the new v1 table, as the old table will soon be deprecated.
```
