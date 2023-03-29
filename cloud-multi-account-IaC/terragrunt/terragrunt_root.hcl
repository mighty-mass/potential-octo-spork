locals {
    vars_account = read_terragrunt_config(find_in_parent_folders("tg_vars_account.hcl"))
    vars_region  = read_terragrunt_config(find_in_parent_folders("tg_vars_region.hcl"))
    vars_stage  = read_terragrunt_config(find_in_parent_folders("tg_vars_stage.hcl"))

    prefix     = "vf-grp-cpsa"
    email_admin_team  = "tbd@vodafone.com"
    email_ops_team    = "tbd@vodafone.com"

    globals = merge(
        local.vars_account.locals,
        local.vars_region.locals,
        local.vars_stage.locals,
        {
            project_id      = "${local.prefix}-${local.vars_stage.locals.stage}-${try(local.vars_account.locals.team_name, local.vars_stage.locals.team_name)}-${local.vars_account.locals.service_number}"
            tf_state_bucket = "${local.prefix}-${local.vars_stage.locals.stage}-cpsoi-01-infrastructure-terraform"
            tf_state_prefix = "${local.vars_stage.locals.stage}/${local.vars_region.locals.region}/${local.vars_account.locals.service_number}-${local.vars_account.locals.service_name}"
            default_labels  = {
                environment = "${local.vars_stage.locals.stage}"
                managedby   = "terraform"
                billing     = "${local.vars_account.locals.service_name}"
                cps-service = "${local.vars_account.locals.service_name}"
            }
        }
    )
    current_folder = basename(get_terragrunt_dir())
    common_dir       = "terraform/compositions"
}

generate "terraform_config" {
    path      = "terraform_config.tf"
    if_exists = "overwrite_terragrunt"
    contents  = <<EOF
      terraform {
        required_providers {
            google = {
                source = "hashicorp/google"
                version = "4.58.0"
            }

            google-beta = {
                source = "hashicorp/google-beta"
                version = "4.58.0"
            }
        }

        required_version = ">= 1.1.0"
        backend "gcs" {
            bucket = "${local.globals.tf_state_bucket}"
            prefix = "${local.globals.tf_state_prefix}/${local.current_folder}"
        }
      }

      provider "google" {
        project = "${local.globals.project_id}"
        region  = "${local.vars_region.locals.region}"
      }

      provider "google-beta" {
        project = "${local.globals.project_id}"
        region  = "${local.vars_region.locals.region}"
      }
  EOF
}

inputs = {
  project_id     = local.globals.project_id
  project_number = local.vars_account.locals.project_number
  service_name   = local.vars_account.locals.service_name
  service_number = local.vars_account.locals.service_number
  region         = local.vars_region.locals.region
  stage          = local.vars_stage.locals.stage
  labels         = local.globals.default_labels
}
