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

# Terraform "vpc" Module vars

variable "vpc_prefix" {
  type = string
}

variable "subnet_prefix" {
  type = string
}

variable "vpc" {
  type = list(object({
    name = string
    routing_mode = string
    # Expected object
    # name = string
    # ip_cidr_range = string
    subnets = list(any)
  }))
}
