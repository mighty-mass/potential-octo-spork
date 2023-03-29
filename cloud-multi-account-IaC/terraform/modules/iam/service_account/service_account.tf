locals {
    flattened_sa_custom_role = flatten([for sa in var.service_account:
            [for role in sa.custom_role : 
                                        tomap({
                                            sa_account_id = sa.account_id, 
                                            role = "projects/${try(role.project_id, var.project_id)}/roles/${role.id}"
                                        })]
    ])

    flattened_sa_default_role = flatten([for sa in var.service_account:
            [for role in sa.default_role : 
                                        tomap({
                                            sa_account_id = sa.account_id, 
                                            role = "roles/${role}"
                                        })]
    ])
}


# Create a Service Account
resource "google_service_account" "service_account" {
    for_each = {for sa in var.service_account: sa.account_id => sa} 

    account_id   = "vf-${var.service_name}-tg-${each.value.account_id}-sa"
    display_name = each.value.display_name
    description  = each.value.description
}

# # Non-Authoritative
# # Assign custom roles to service account
# resource "google_service_account_iam_member" "service_account_binding_custom_role" {
#     for_each =  {for pair in local.flattened_sa_custom_role: index(local.flattened_sa_custom_role, pair) => pair}

#     service_account_id = google_service_account.service_account[each.value.sa_account_id].id
#     role    = each.value.role
#     member = "serviceAccount:${google_service_account.service_account[each.value.sa_account_id].email}"
# }

# # Non-Authoritative
# # Assign default roles to service account
# resource "google_service_account_iam_member" "service_account_binding_default_role" {
#     for_each =  {for pair in local.flattened_sa_default_role: index(local.flattened_sa_default_role, pair) => pair}

#     service_account_id = google_service_account.service_account[each.value.sa_account_id].id
#     role    = each.value.role
#     member = "serviceAccount:${google_service_account.service_account[each.value.sa_account_id].email}"
# }

#Authoritative
# Assign default roles to service account
resource "google_project_iam_binding" "service_account_binding_default_role" {
    for_each =  {for pair in local.flattened_sa_default_role: index(local.flattened_sa_default_role, pair) => pair}

    project = var.project_id
    role    = each.value.role
    members = ["serviceAccount:${google_service_account.service_account[each.value.sa_account_id].email}"]
}

#Authoritative
# Assign custom roles to service account
resource "google_project_iam_binding" "service_account_binding_custom_role" {
    for_each =  {for pair in local.flattened_sa_custom_role: index(local.flattened_sa_custom_role, pair) => pair}

    project = var.project_id
    role    = each.value.role
    members = ["serviceAccount:${google_service_account.service_account[each.value.sa_account_id].email}"]
}

# Create service account key
# NOTE: not in used ATM, since can't be shared with the targe audience programmaticly
# resource "time_rotating" "key_rotation_period" {
#     for_each = {for sa in var.service_account:  sa.account_id => sa if contains(keys(sa), "key")}

#     rotation_days = 30
# }

# resource "google_service_account_key" "service_account_key" {
#     for_each = {for sa in var.service_account:  sa.account_id => sa if contains(keys(sa), "key")}

#     service_account_id = google_service_account.service_account[each.value.account_id].name

#     keepers = {
#         rotation_time = time_rotating.key_rotation_period[each.value.account_id].rotation_rfc3339
#     }
# }
