locals {
  region = "eu-west-1"
  azs    = ["${local.region}a", "${local.region}b", "${local.region}c"]
}