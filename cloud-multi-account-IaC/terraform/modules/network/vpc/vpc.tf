locals {
    flattened_vpc_subnets = flatten([for vpc in var.vpc:
            [for subnet in vpc.subnets : 
                                        tomap({
                                            vpc_name = vpc.name, 
                                            subnet_name = subnet.name
                                            subnet_ip_cidr_range = subnet.ip_cidr_range
                                            })]
    ])

    flattened_vpc_ip_ranges = {for vpc in var.vpc:
                                    vpc.name => [for subnet in vpc.subnets:
                                                subnet.ip_cidr_range
                                            ]
    }
}

resource "google_compute_network" "vpc_network" {
    for_each = {for vpc in var.vpc: vpc.name => vpc}
    project = var.project_id
    routing_mode = each.value.routing_mode
    auto_create_subnetworks = false
    name = "${var.vpc_prefix}-${each.value.name}-${var.stage}-${var.service_name}"
}


resource "google_compute_subnetwork" "vpc_subnetwork" {
    for_each = {for pair in local.flattened_vpc_subnets: "${pair.vpc_name}-${index(local.flattened_vpc_subnets, pair)}" => pair}

    name = "${var.subnet_prefix}-${each.value.subnet_name}-${var.stage}-${var.service_name}"
    ip_cidr_range = each.value.subnet_ip_cidr_range
    region        = var.region
    network       = google_compute_network.vpc_network[each.value.vpc_name].id

    private_ip_google_access = true

    log_config {
        metadata = "INCLUDE_ALL_METADATA"
    }
}

resource "google_compute_firewall" "internal_comm" {
    for_each = local.flattened_vpc_ip_ranges

    name    = "allow-private-ip-internal-comm"
    network = google_compute_network.vpc_network[each.key].name

    allow {
        protocol = "all"
    }

    priority = "65535"
    source_ranges = each.value

    log_config {
        metadata = "INCLUDE_ALL_METADATA"
    }
}
