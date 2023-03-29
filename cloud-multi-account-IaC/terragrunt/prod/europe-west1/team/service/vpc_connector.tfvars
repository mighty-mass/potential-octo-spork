# NOTE: There is no VPC network creation because it was handled by another team and tey provided the values
# One quick implemntetation would be to remove the VPC Connector variables and create all the resource via module in Terraform
vpc_connector = [{
    name = "gae-email"
    network = "<vpc_network>"
    subnet = "<subnet_network>"
    project_id = "<project_id>"
}]
