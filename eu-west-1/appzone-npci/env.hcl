locals {
  owner              = "cloudapp-npci"
  env                = "preprod"
  cidr               = "10.255.0.0/20"
  intra_subnets      = []
  database_subnets   = ["10.255.0.0/24", "10.255.1.0/24"]
  public_subnets     = ["10.255.2.0/24", "10.255.3.0/24"]
  private_subnets    = ["10.255.4.0/24", "10.255.5.0/24"]
  enable_nat_gateway = false
  enable_vpn_gateway = false
}