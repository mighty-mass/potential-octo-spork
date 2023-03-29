# Global Terragrunt vars

variable "project_id" {
  description = "Project Id"
  type = string
}

variable "project_number" {
  description = "Project Number"
  type = string
}

variable "service_name" {
  description = "Service Name"
  type = string
}

variable "service_number" {
  description = "Service Number"
  type = string
}

variable "stage" {
  description = "Preprod or Prod"
  type = string
}

variable "region" {
  description = "GCP Region"
  type = string
}

variable "labels" {
  type = any
  description = "Default labels"
}

# Terraform Module vars
variable "logging_sink_name" {
  description = "The name of logging sink"
  type = string
}

variable "logging_sink_description" {
  description = "The description of logging sink"
  type = string
}

variable "logging_sink_type" {
  description = "One among pubsub, bigquery, storage or logging"
  type = string
}

variable "logging_sink_project_id" {
  description = "The project id where the sink is"
  type = string
  default = null
}
variable "logging_sink_destination_name" {
  description = "The name of the sink (either a pubsub topic, logging log, bigquery dataset or storage bucket)"
  type = string
}
variable "logging_sink_filter" {
  description = "filters to apply to logs"
  type = string
}

variable "service_account_name" {
  description = "Service account"
  type = string
}
