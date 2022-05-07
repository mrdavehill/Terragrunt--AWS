terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc.git//.?ref=v3.14.0"
}

locals {
  env_vars           = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env                = local.env_vars.locals.env
  product            = local.env_vars.locals.product
  name               = "${local.product}-${local.env}"
  cidr               = local.env_vars.locals.cidr
  intra_subnets      = local.env_vars.locals.intra_subnets
  database_subnets   = local.env_vars.locals.database_subnets
  public_subnets     = local.env_vars.locals.public_subnets
  private_subnets    = local.env_vars.locals.private_subnets
  enable_nat_gateway = local.env_vars.locals.enable_nat_gateway
  enable_vpn_gateway = local.env_vars.locals.enable_vpn_gateway
  region_vars        = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  azs                = local.region_vars.locals.azs
  tags               = {
    Terraform        = "true"
    Environment      = local.env
  }
}

inputs = {
  name               = local.name
  cidr               = local.cidr
  azs                = local.azs
  intra_subnets      = local.intra_subnets
  database_subnets   = local.database_subnets
  public_subnets     = local.public_subnets
  private_subnets    = local.private_subnets
  enable_nat_gateway = local.enable_nat_gateway
  enable_vpn_gateway = local.enable_vpn_gateway
  tags               = merge(local.tags)
}