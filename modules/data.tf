####################################################################
# Create list of subnets
####################################################################
data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

####################################################################
# Create list of instances based on the subnets
####################################################################
data "aws_instances" "this" {
  filter {
    name   = "subnet-id"
    values = data.aws_subnets.this.ids
  }
}

####################################################################
# Create list of all volumes attached to instances
####################################################################
data "aws_ebs_volumes" "this" {
  filter {
    name   = "attachment.instance-id"
    values = data.aws_instances.this.ids
  } 
}

####################################################################
# Create list of all NGWs
####################################################################
data "aws_nat_gateways" "this" {
  vpc_id = var.vpc_id
}

####################################################################
# Create list of all NACLs
####################################################################
data "aws_network_acls" "this" {
  vpc_id = var.vpc_id
}

####################################################################
# Create list of all vpc peerings
####################################################################
data "aws_vpc_peering_connections" "this" {
  filter {
    name   = "requester-vpc-info.vpc-id"
    values = [var.vpc_id]
  }
}

####################################################################
# Create list of all vpc route tables
####################################################################
data "aws_route_tables" "this" {
  vpc_id = var.vpc_id
}

####################################################################
# Create list of all vpc security groups
####################################################################
data "aws_security_groups" "this" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

####################################################################
# Create list of all network interfaces
####################################################################
data "aws_network_interfaces" "this" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

///####################################################################
///# The internet gateway
///####################################################################
///data "aws_internet_gateway" "this" {
///  filter {
///    name   = "attachment.vpc-id"
///    values = [var.vpc_id]
///  }
///}

///####################################################################
///# vgw
///####################################################################
///data "aws_vpn_gateway" "this" {
///  attached_vpc_id = var.vpc_id
///}