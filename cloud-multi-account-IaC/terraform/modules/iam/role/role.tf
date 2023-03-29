locals{
    flattened_role_permissions = try({for role in var.custom_role: role.id => 
        flatten([for service in keys(role.permissions) :
                                    [
                                    for type in keys(role.permissions[service]) : [
                                        for action in role.permissions[service][type]:
                                            "${service}.${type}.${action}"
                                    ]]
                                ])
    }, {})
}

resource "google_project_iam_custom_role" "custom_role" {
    for_each = {for role in var.custom_role:  role.id => role}

    role_id     = each.value.id
    title       = each.value.title
    description = each.value.description
    permissions = local.flattened_role_permissions[each.value.id]
}
