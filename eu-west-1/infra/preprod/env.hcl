locals {
  owner                       = "infra"
  env                         = "preprod"
  transit_gateway_cidr_blocks = ["10.255.0.0/16"]
  #vpc_routes                  = "0.0.0.0/0"

  amazon_side_asn             = "65001"
}