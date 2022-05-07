locals {
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  region           = local.region_vars.locals.region
}

remote_state {
  backend          = "s3"
  generate         = {
    path           = "backend.tf"
    if_exists      = "overwrite"
  }
  config = {
    bucket         = "mrdavehill-demo-backend"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    dynamodb_table = "my-lock-table"
  }
}
