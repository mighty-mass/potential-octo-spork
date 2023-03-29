module "vpc_connector" {
  source         = "../../modules/network/vpc_connector"
  project_id     = var.project_id
  project_number = var.project_number
  service_name   = var.service_name
  service_number = var.service_number
  region         = var.region
  stage          = var.stage 
  labels         = var.labels

  vpc_connector_prefix = var.vpc_connector_prefix
  vpc_connector        = var.vpc_connector
}

module "service_account" {
  source         = "../../modules/iam/service_account"
  project_id     = var.project_id
  project_number = var.project_number
  service_name   = var.service_name
  service_number = var.service_number
  region         = var.region
  stage          = var.stage 
  labels         = var.labels

  service_account = var.service_account
}

module "gae_service" {
  source  = "../../modules/app_engine/service"
  project_id     = var.project_id
  project_number = var.project_number
  service_name   = var.service_name
  service_number = var.service_number
  region         = var.region
  stage          = var.stage 
  labels         = var.labels
  
  service_account  = module.service_account.service_account["gae-email"].email
  vpc_connector   = module.vpc_connector.vpc_connector["gae-email"].id

  gae_prefix  = var.gae_prefix
  gae_service = var.gae_service
}
