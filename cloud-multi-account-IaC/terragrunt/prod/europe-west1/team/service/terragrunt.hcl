include "root" {
  path   = find_in_parent_folders("terragrunt_root.hcl")
  expose = true
}

locals {
  repo_root_dir = "${get_parent_terragrunt_dir("root")}/.."
  common_dir    = include.root.locals.common_dir
  globals       = include.root.locals.globals
}

terraform {
  source = "${local.repo_root_dir}//${local.common_dir}/${basename(get_original_terragrunt_dir())}"

  extra_arguments "custom_vars" {
    commands = get_terraform_commands_that_need_vars()

    arguments = [
      "-var-file=${get_terragrunt_dir()}/gae_service.tfvars",
      "-var-file=${get_terragrunt_dir()}/service_account.tfvars",
      "-var-file=${get_terragrunt_dir()}/vpc_connector.tfvars"
    ]
  }
}
