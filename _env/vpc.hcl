terraform {
  source = "../../../../modules//terraform-aws-vpc"
}

locals {
  env_vars           = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env                = local.env_vars.locals.env
  owner              = local.env_vars.locals.owner
  name               = "${local.owner}-${local.env}"
  cidr               = local.env_vars.locals.cidr
  intra_subnets      = local.env_vars.locals.intra_subnets
  database_subnets   = local.env_vars.locals.database_subnets
  public_subnets     = local.env_vars.locals.public_subnets
  private_subnets    = local.env_vars.locals.private_subnets
  enable_nat_gateway = local.env_vars.locals.enable_nat_gateway
  enable_vpn_gateway = local.env_vars.locals.enable_vpn_gateway
  account_id         = data.aws_caller_identity.current.account_id
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

  enable_flow_log                                 = true
  create_flow_log_cloudwatch_log_group            = true
  flow_log_cloudwatch_log_group_name_prefix       = "${local.name}/flowlogs"
  flow_log_cloudwatch_log_group_retention_in_days = 3
  flow_log_destination_arn                        = get_aws_caller_identity_arn()
  flow_log_cloudwatch_iam_role_arn                = "arn:aws:iam::${local.account_id}:role/aws-service-role/organizations.amazonaws.com/AWSServiceRoleForOrganizations"
  tags                                            = merge(local.tags)
}