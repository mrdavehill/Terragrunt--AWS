terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-transit-gateway//.?ref=v2.7.0"
}

locals {
  env_vars                              = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env                                   = local.env_vars.locals.env
  owner                                 = local.env_vars.locals.owner
  name                                  = "tgw-${local.owner}-${local.env}"
  amazon_side_asn                       = local.env_vars.locals.amazon_side_asn
  transit_gateway_cidr_blocks           = local.env_vars.locals.transit_gateway_cidr_blocks
}

dependency "appzone-pci" {
  config_path = "../appzone-pci/${local.env}/vpc"
}

dependency "appzone-npci" {
  config_path = "../appzone-npci/${local.env}/vpc"
}

dependency "cloudsec" {
  config_path = "../cloudsec/${local.env}/vpc"
}

inputs = {
  name                                  = local.name
  description                           = "${local.env} Transit Gateway"
  amazon_side_asn                       = local.amazon_side_asn

  transit_gateway_cidr_blocks           = local.transit_gateway_cidr_blocks
  enable_auto_accept_shared_attachments = true

  vpc_attachments = {
    appzone-pci                         = {
      vpc_id                            = dependency.vpc.outputs.appzone-pci.vpc_id
      subnet_ids                        = dependency.vpc.outputs.appzone-pci.private_subnets
      dns_support                       = true
      ipv6_support                      = false

      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false

      tgw_routes = [
        {
          destination_cidr_block = "20.0.0.0/16"
        },
        {
          blackhole              = true
          destination_cidr_block = "0.0.0.0/0"
        }
      ]
    },
    appzone-npci                         = {
      vpc_id                            = dependency.vpc.outputs.appzone-npci.vpc_id
      subnet_ids                        = dependency.vpc.outputs.appzone-npci.private_subnets
      dns_support                       = true
      ipv6_support                      = false

      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false

      tgw_routes = [
        {
          destination_cidr_block = "30.0.0.0/16"
        },
        {
          blackhole              = true
          destination_cidr_block = "0.0.0.0/0"
        }
      ]
    },
    cloudsec = {
      vpc_id                            = dependency.vpc.outputs.cloudsec.vpc_id
      subnet_ids                        = dependency.vpc.outputs.cloudsec.private_subnets
      dns_support                       = true
      ipv6_support                      = false

      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false


      tgw_routes = [
        {
          destination_cidr_block = "50.0.0.0/16"
        },
        {
          blackhole              = true
          destination_cidr_block = "10.10.10.10/32"
        }
      ]
    },
  }

  ram_allow_external_principals = true
  ram_principals                = [307990089504]

  tags = local.tags
}
}