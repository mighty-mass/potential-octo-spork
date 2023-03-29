locals {

  threshold_in_bytes = 1000000000000
  logging_sink_project_id = var.logging_sink_project_id == null ? var.project_id : var.logging_sink_project_id

  destinations = {
    pubsub   = "pubsub.googleapis.com/projects/${local.logging_sink_project_id}/topics/${var.logging_sink_destination_name}"
    bigquery = "bigquery.googleapis.com/projects/${local.logging_sink_project_id}/datasets/${var.logging_sink_destination_name}"
    storage  = "storage.googleapis.com/${var.logging_sink_destination_name}"
    logging  = "logging.googleapis.com/projects/${local.logging_sink_project_id}/locations/global/buckets/${var.logging_sink_destination_name}"
  }

  email_address = ["dl-gtcpsdataanalyticssupport@vodafone.com", "dl-voisecpsplatformeng@vodafone.com"]
}

resource "google_logging_project_sink" "logging_sink" {
  name        = var.logging_sink_name
  description = var.logging_sink_description

  # Can export to pubsub, cloud storage, or bigquery 
  # (Splunk not added yet in Terraform)
  destination = local.destinations[var.logging_sink_type]

  # Log all WARN or higher severity messages relating to instances
  filter = <<DOC
resource.type="bigquery_resource" 
protoPayload.serviceData.jobCompletedEvent.eventName="query_job_completed" 
protoPayload.serviceData.jobCompletedEvent.job.jobStatistics.totalBilledBytes >= "${local.threshold_in_bytes}"
  DOC 

  dynamic "bigquery_options" {
    for_each = var.logging_sink_type == "bigquery" ? [1] : []
    content{
      use_partitioned_tables = true
    }
  }

  unique_writer_identity = var.logging_sink_type == "bigquery" ? true : false
}

resource "google_bigquery_dataset" "bigquery_logs" {
  dataset_id = var.logging_sink_destination_name
  location               = var.region

  default_partition_expiration_ms = 1296000000 #1 day = 86400000
  delete_contents_on_destroy = true

  labels = var.labels

  access {
    role           = "OWNER"
    group_by_email = "gcp-vf-grp-cpsa-ciot-adap-data-engineer-core@vodafone.com"
  }

  access {
    role          = "OWNER"
    user_by_email = substr(google_logging_project_sink.logging_sink.writer_identity, 15, 80)
  }

  access {
    role   = "READER"
    domain = "vodafone.com"
  }
}

resource "google_bigquery_data_transfer_config" "query_config" {
  display_name           = "[SQ] ${var.logging_sink_name}"
  location               = var.region
  data_source_id         = "scheduled_query"
  schedule               = "every day 00:00"

  service_account_name = var.service_account_name

  params = {
    query = <<DOC
with subquery1 as(
  select date(timestamp) as Date,sum(cast(protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.totalProcessedBytes / ${local.threshold_in_bytes} as numeric)) as TB,sum(cast(5.0*
      (protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.totalProcessedBytes/POWER(2,40))
      as numeric
      )) as CostInUSD
  FROM `${var.project_id}.${google_bigquery_dataset.bigquery_logs.dataset_id}.cloudaudit_googleapis_com_data_access`
  WHERE protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.eventName="query_job_completed"
    AND protopayload_auditlog.servicedata_v1_bigquery.jobCompletedEvent.job.jobStatistics.totalProcessedBytes IS NOT NULL
  group by 1
),
subquery2 as (
  select date,CostInUSD,avg(CostInUSD) OVER(
  ORDER BY date
  ROWS BETWEEN 6 PRECEDING AND CURRENT ROW ) as sevenday_moving_average
  from subquery1
  group by 1,2
  order by date desc
),
subquery3 as(
  select t2.date,t2.CostInUSD ,t2.sevenday_moving_average,lag(t2.sevenday_moving_average) OVER (ORDER BY t2.Date ASC) as prevweek_MA_cost
  from subquery1 as t1,subquery2 as t2
  group by 1,2,3
  order by 1 desc
  limit 1
)

select
IF(subquery3.CostInUSD> subquery3.prevweek_MA_cost+5 ,ERROR("query exceeded last week billing AVG"), "F") 
from subquery3
    DOC
    }
}


resource "google_monitoring_notification_channel" "email_notification" {
  for_each = toset(local.email_address)

  display_name = "Custom Channels for Notifications via email"
  type = "email"

  labels = {
    email_address = each.key
  }

  user_labels = var.labels
}

resource "google_monitoring_alert_policy" "alert_policy" {
  display_name = "[CPSOI] ${var.logging_sink_name}"
  combiner     = "OR"
  conditions {
    display_name = "Error Condition"
    condition_matched_log {
      filter     = <<DOC
resource.type="bigquery_resource"
protoPayload.serviceData.jobCompletedEvent.eventName="query_job_completed"
protoPayload.serviceData.jobCompletedEvent.job.jobStatistics.referencedTables.datasetId= "${var.logging_sink_destination_name}"
protoPayload.status.message="query exceeded last week billing AVG"
severity=ERROR
      DOC
    }
  }

  user_labels = var.labels

  notification_channels = [ for email in google_monitoring_notification_channel.email_notification: email.name ]

  alert_strategy {
    notification_rate_limit {
      period = "300s"
    }
  }
}
