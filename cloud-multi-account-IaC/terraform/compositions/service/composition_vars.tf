
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

# Terraform "vpc_connector" Module vars

variable "vpc_connector_prefix" {
  type = string
  default = "vpc-conn"
}

variable "vpc_connector" {
  type = list(object({
    name = string
    network = string
    subnet = string
    project_id = any
  }))
}


# Terraform "service_accounts" Module vars

variable "service_account" {
  type = list(object({
    account_id   = string
    display_name = string
    description  = string
    custom_role  = list(object({
      project_id = string
      id = string
    }))
    default_role = list(string)
  }))
  description = "Service Accounts"
  default = []
}

# Terraform "gae_service" Module vars

variable "gae_prefix" {
  type = string
  default = "gae"
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
