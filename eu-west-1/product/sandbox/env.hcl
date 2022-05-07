locals {
  product            = "cloudapp"
  env                = "sandbox"
  cidr               = "10.255.32.0/20"
  intra_subnets      = ["10.255.32.0/24", "10.255.33.0/24"]
  database_subnets   = ["10.255.34.0/24", "10.255.35.0/24"]
  public_subnets     = []
  private_subnets    = []
  enable_nat_gateway = false
  enable_vpn_gateway = false
}