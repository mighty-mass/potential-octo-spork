locals {
  kms_keyring = coalesce(var.kms_keyring, "${var.service_name}-${var.stage}-keyring")
  kms_key = coalesce(var.kms_key, "${var.stage}-cpsoi-${var.service_number}-${var.service_name}-storage-key")
  cpsoi_mgt_key_path = "projects/vf-grp-cpsa-mgt-cpsoi-01/locations/${var.region}/keyRings/${local.kms_keyring}/cryptoKeys/${local.kms_key}"

  composer_related_sa = [
    "serviceAccount:service-${var.project_number}@cloudcomposer-accounts.iam.gserviceaccount.com",
    "serviceAccount:service-${var.project_number}@compute-system.iam.gserviceaccount.com",
    "serviceAccount:service-${var.project_number}@gcp-sa-pubsub.iam.gserviceaccount.com",
    "serviceAccount:service-${var.project_number}@gs-project-accounts.iam.gserviceaccount.com",
    "serviceAccount:service-${var.project_number}@container-engine-robot.iam.gserviceaccount.com",
    "serviceAccount:service-${var.project_number}@gcp-sa-artifactregistry.iam.gserviceaccount.com",
    "serviceAccount:service-${var.project_number}@dataproc-accounts.iam.gserviceaccount.com"
  ]

  default_allowed_ip_ranges = [{
      ip_range = "173.194.73.0/24"
      description = "Default Vodafone VPN"
    },
    {
      ip_range = "74.125.73.0/24"
      description = "Default Vodafone VPN"
    },
    {
      ip_range = "195.233.26.80/28"
      description = "Default Vodafone VPN"
    },
    {
      ip_range = "195.14.245.56"
      description = "Default Vodafone VPN"
    },
    {
      ip_range = "95.223.57.0/24"
      description = "Default Vodafone VPN"
    }
  ]
}

resource "google_project_iam_member" "composer-iam-v2-api" {
  project  = var.project_id
  role     = "roles/composer.ServiceAgentV2Ext"
  member   = "serviceAccount:service-${var.project_number}@cloudcomposer-accounts.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "composer-iam-dataproc" {
  project  = var.project_id
  role     = "roles/dataproc.serviceAgent"
  member   = "serviceAccount:service-${var.project_number}@dataproc-accounts.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "composer-iam-dataproc-metastore" {
  project  = var.project_id
  role     = "roles/metastore.serviceAgent"
  member   = "serviceAccount:service-${var.project_number}@dataproc-accounts.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "composer-iam-compute" {
  project  = var.project_id
  role     = "roles/compute.serviceAgent"
  member   = "serviceAccount:service-${var.project_number}@compute-system.iam.gserviceaccount.com"
}

resource "google_kms_crypto_key_iam_member" "sa-key-access" {
  for_each = toset(local.composer_related_sa)

  crypto_key_id = local.cpsoi_mgt_key_path
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = each.key
}

resource "google_composer_environment" "composer-instance" {
  provider = google-beta

  name = "${var.composer_name_prefix}-${var.service_name}-${var.stage}-${var.composer_name_suffix}"
  project = var.project_id
  region = var.region
  labels = var.labels 

  config {
    node_config {
      # zone = ""
      # machine_type = ""
      network = "projects/${var.project_id}/global/networks/${var.network}"
      subnetwork = "projects/${var.project_id}/regions/${var.region}/subnetworks/${var.subnetwork}"
      service_account = var.service_account
      # oauth_scopes = []
      # tags = []
    }
    software_config {
      airflow_config_overrides = var.airflow_config_overrides
      env_variables = {}
      image_version = var.airflow_version
      pypi_packages = var.pypi_packages
    }
    private_environment_config {
      enable_private_endpoint = true
    }
    web_server_network_access_control {
      dynamic allowed_ip_range {
        for_each = concat(local.default_allowed_ip_ranges, var.allowed_ip_ranges)
        content {
          value = allowed_ip_range.value.ip_range
          description = allowed_ip_range.value.description
        }
      }
    }
    environment_size = var.environment_size
    encryption_config {
      kms_key_name = local.cpsoi_mgt_key_path
    }
    maintenance_window {
      start_time = var.maintenance_window.start_time
      recurrence = var.maintenance_window.recurrence
      end_time   = var.maintenance_window.end_time
    }
    workloads_config {
      scheduler {
        count = var.workloads_config.scheduler.count
        cpu = var.workloads_config.scheduler.cpu
        memory_gb = var.workloads_config.scheduler.memory_gb
        storage_gb = var.workloads_config.scheduler.storage_gb
      }
      web_server {
        cpu = var.workloads_config.web_server.cpu
        memory_gb = var.workloads_config.web_server.memory_gb
        storage_gb = var.workloads_config.web_server.storage_gb
      }
      worker {
        cpu = var.workloads_config.worker.cpu
        min_count = var.workloads_config.worker.min_count
        max_count = var.workloads_config.worker.max_count
        memory_gb = var.workloads_config.worker.memory_gb
        storage_gb = var.workloads_config.worker.storage_gb
      }
    }
  }
  depends_on = [
    google_project_iam_member.composer-iam-v2-api,
    google_kms_crypto_key_iam_member.sa-key-access
  ]
}

# NB: Not working atm due to restricted access to the composer GKE env
# Will be useful to create programmatic connections inside Airflow
# resource "null_resource" "add_airflow_connnections" {
#   for_each = {for connection in var.airflow_custom_connections: connection.conn_id => connection}

#   provisioner "local-exec" {
#     command = "gcloud composer environments run ${google_composer_environment.composer-instance.name} --location ${var.region} connections -- --add --conn_id=${each.value.conn_id} --conn-type=${each.value.conn_type} --description='${each.value.description}' --host=${each.value.host} --login=${each.value.login} --conn-extra '${jsonencode(each.value.conn_extra)}'"
#   }

#   depends_on = [google_composer_environment.composer-instance]
# }


# resource "null_resource" "add_airflow_variables" {
#   for_each = var.airflow_custom_variables

#   provisioner "local-exec" {
#       command = "gcloud composer environments run ${google_composer_environment.composer-instance.name} --location ${var.region} variables -- --set ${each.key} ${each.value}"
#       }

#   depends_on = [google_composer_environment.composer-instance]
# }
