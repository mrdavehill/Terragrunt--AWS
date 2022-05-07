locals {
  product = "cloud"
  env = "preprod"
  cidr = "10.255.16.0/20"
  intra_subnets = ["10.255.16.0/24", "10.255.17.0/24"]
  database_subnets  = ["10.255.18.0/24", "10.255.19.0/24"]
  enable_nat_gateway = false
  enable_vpn_gateway = false
}