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
  default = {}
}

# Terraform "service_accounts" Module vars

variable "service_account" {
  type = list(object({
    account_id   = string
    display_name = string
    description  = string
    # Expected for custom role
    # project_id = string
    # id = string
    custom_role  = list(any)
    default_role = list(string)
  }))
  description = "Service Accounts"
}
