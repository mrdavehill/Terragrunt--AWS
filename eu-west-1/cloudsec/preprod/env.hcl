locals {
  owner              = "cloudsec"
  env                = "preprod"
  cidr               = "10.255.64.0/20"
  intra_subnets      = ["10.255.65.0/24", "10.255.66.0/24"]
  database_subnets   = []
  public_subnets     = ["10.255.67.0/24", "10.255.68.0/24"]
  private_subnets    = ["10.255.69.0/24", "10.255.70.0/24"]
  enable_nat_gateway = false
  enable_vpn_gateway = false
}