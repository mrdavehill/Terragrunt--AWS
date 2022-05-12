terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-transit-gateway//.?ref=v2.7.0"
}

locals {
  env_vars                              = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env                                   = local.env_vars.locals.env
  owner                                 = local.env_vars.locals.owner
  name                                  = "tgw-${local.owner}-${local.env}"
  amazon_side_asn                       = local.env_vars.locals.amazon_side_asn
  tags               = {
    Terraform        = "true"
    Environment      = local.env
  }
}

dependency "appzone-pci" {
  config_path = "../../../appzone-pci/${local.env}/vpc"
}

dependency "appzone-npci" {
  config_path = "../../../appzone-npci/${local.env}/vpc"
}

dependency "cloudsec" {
  config_path = "../../../cloudsec/${local.env}/vpc"
}

inputs = {
  name                                  = local.name
  description                           = "${local.env} Transit Gateway"
  amazon_side_asn                       = local.amazon_side_asn

  #transit_gateway_cidr_blocks           = local.transit_gateway_cidr_blocks
  enable_auto_accept_shared_attachments = true

  vpc_attachments = {
    appzone-pci                         = {
      vpc_id                            = dependency.appzone-pci.outputs.vpc_id
      subnet_ids                        = dependency.appzone-pci.outputs.intra_subnets
      dns_support                       = true
      ipv6_support                      = false
      vpc_route_table_ids               = dependency.appzone-pci.outputs.intra_route_table_ids
      tgw_destination_cidr              = "0.0.0.0/0"
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = true

    },
    appzone-npci                        = {
      vpc_id                            = dependency.appzone-npci.outputs.vpc_id
      subnet_ids                        = dependency.appzone-npci.outputs.private_subnets
      dns_support                       = true
      ipv6_support                      = false
      vpc_route_table_ids               = dependency.appzone-npci.outputs.private_route_table_ids
      tgw_destination_cidr              = "0.0.0.0/0"
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = true

    },
    cloudsec = {
      vpc_id                            = dependency.cloudsec.outputs.vpc_id
      subnet_ids                        = dependency.cloudsec.outputs.private_subnets
      dns_support                       = true
      ipv6_support                      = false
      transit_gateway_default_route_table_association = true
      transit_gateway_default_route_table_propagation = true
      
      tgw_routes = [
        {
          destination_cidr_block = "0.0.0.0/0"
        }
      ]
    }
  }

  share_tgw                      = false  

  tags                          = merge(local.tags)
}