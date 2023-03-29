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

# Terraform "vpc_connector" Module vars

variable "vpc_connector_prefix" {
  type = string
}

variable "vpc_connector" {
  type = list(object({
    name = string
    network = string
    subnet = string
    project_id = any
  }))
}
