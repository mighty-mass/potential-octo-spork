service_account = [
    {
        account_id      = "gae-email"
        display_name    = "App Engine Email Service Account"
        description     = "SA to manage App Engine Environment"
        custom_role = [
            # {
            #     id = "vfcpsaServiceAccount"
            #     project_id = "vf-grp-cpsa-prd-cpsoi-01"
            # }
        ]
        default_role = [
            "appengine.appCreator",
            "appengine.deployer",
            "secretmanager.secretAccessor",
            "storage.objectViewer"
        ]
    }
]
