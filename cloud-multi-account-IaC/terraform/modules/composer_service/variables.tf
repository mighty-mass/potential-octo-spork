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

variable "composer_name_prefix" {
  type = string
  description = "The composer name prefix"
}

variable "composer_name_suffix" {
  type = string
  description = "The composer suffix, usually the version"
}

variable "airflow_version" {
  type = string
  description = "The composer and airflow versions to launch instance in GCP"
}

variable "network" {
  description = "Name of the VPC network for use with the Composer instance."
  type = string
}

variable "subnetwork" {
  description = "Name of the VPC subnetwork for use with the Composer instance."
  type = string
}

variable "service_account" {
  description = "service account name"
  type = string
}

variable "pypi_packages" {
  description = ""
  type = map(string)
}

variable allowed_ip_ranges {
  type = list(object({
    ip_range = string
    description = string
  }))
}

variable environment_size {
  type = string
}

variable "kms_keyring" {
  type = string
}

variable "kms_key" {
  type = string
}
variable maintenance_window {
  type = object({
    start_time = string
    end_time = string
    recurrence = string
  })
}

variable "workloads_config" {
  description = "Contains configuration for resources used by Airflow schedulers, web server and workers"
  type = object({
    scheduler = object({
      count = string
      cpu = string
      memory_gb = string
      storage_gb = string
    })
    web_server = object({
      cpu = string
      memory_gb = string
      storage_gb = string
    })
    worker = object({
      cpu = string
      min_count = string
      max_count = string
      memory_gb = string
      storage_gb = string
    })
  })
}

variable "airflow_config_overrides"{
  description = "AirFlow custom configurations"
}

variable "airflow_custom_connections"{
  description = "AirFlow custom connections"

  type = list(object({
    conn_id = string
    description = string
    conn_type = string
    host = string
    login = string
    conn_extra = any
  }))
}

variable "airflow_custom_variables" {
  description = "AirFlow custom variables"

  type = map
}
