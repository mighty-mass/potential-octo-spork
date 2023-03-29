resource "google_app_engine_standard_app_version" "app_engine_service" {
    for_each = {for service in var.gae_service:  service.service => service}

    version_id = each.value.version
    service    = "${var.gae_prefix}-${each.value.service}"
    runtime    = each.value.runtime

    entrypoint {
        shell = each.value.entrypoint
    }

    deployment {
        dynamic "files"{
            for_each = each.value.files
            content {
                name = files.value.name
                source_url = files.value.source_url
            }
        }
    }

    env_variables = each.value.env_variables

    # dynamic "libraries"{
    #     for_each = each.value.libraries
    #     content {
    #         name = libraries.value.name
    #         version = libraries.value.version
    #     }
    # }

    vpc_access_connector {
        name           = var.vpc_connector
        egress_setting = "ALL_TRAFFIC"
    }

    delete_service_on_destroy = true
    service_account = var.service_account
}

resource "google_app_engine_service_network_settings" "internal_only" {
    for_each = google_app_engine_standard_app_version.app_engine_service

    service = each.value.service
    network_settings {
        ingress_traffic_allowed = "INGRESS_TRAFFIC_ALLOWED_INTERNAL_ONLY"
    }
}
