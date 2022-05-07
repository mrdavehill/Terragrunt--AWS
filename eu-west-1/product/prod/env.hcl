locals {
  product            = "cloudapp"
  env                = "prod"
  cidr               = "10.255.0.0/20"
  intra_subnets      = ["10.255.1.0/24", "10.255.1.0/24"]
  database_subnets   = ["10.255.2.0/24", "10.255.3.0/24"]
  public_subnets     = []
  private_subnets    = []
  enable_nat_gateway = false
  enable_vpn_gateway = false
}