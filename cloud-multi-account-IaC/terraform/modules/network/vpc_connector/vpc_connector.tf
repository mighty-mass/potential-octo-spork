resource "google_vpc_access_connector" "connector" {
    for_each = {for vpc_conn in var.vpc_connector:  vpc_conn.name => vpc_conn}

    name          = "${var.vpc_connector_prefix}-${each.value.name}"
    region        = var.region
    project       = var.project_id
    #network       = each.value.network

    subnet {
        name       = each.value.subnet
        project_id = each.value.project_id != null ? each.value.project_id : var.project_id
    }

    machine_type = "e2-micro"
    min_instances = 2
    max_instances = 3
}
