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

# Terraform "gae_service" Module vars

variable "gae_prefix" {
  type = string
}

variable "gae_service" {
  type = list(object({
    version = string
    service = string
    runtime = string
    entrypoint = string
    files = list(object({
      name       = string
      source_url = string
    }))
    libraries = list(object({
      name    = string
      version = string
    }))
    env_variables = map(string)
  }))
}

variable "service_account" {
  description = "service account name"
  type = string
}
variable "vpc_connector" {
  description = "vpc connector id"
  type = string
}
