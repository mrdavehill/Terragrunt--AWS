####################################################################################################
# Transform data into list of objects containing tag
# variables from env.hcl and AWS IDs from data sources
####################################################################################################
locals {

  helper                = tolist([var.vpc_id                     # These are strings and need to be
                            #data.aws_vpn_gateway.this.id,       # converted to a single list before
                            #data.aws_internet_gateway.this.id   # they can be used.
                            ])                                   # The IGW & VGW are commented out
                                                                 # because they break the script when run
                                                                 # in a VPC that doesn't have IGW or VGW :(
  data_sources          = concat(local.helper,
                            data.aws_instances.this.ids, data.aws_ebs_volumes.this.ids, 
                            data.aws_nat_gateways.this.ids, data.aws_subnets.this.ids, 
                            data.aws_network_acls.this.ids, data.aws_vpc_peering_connections.this.ids,
                            data.aws_route_tables.this.ids, data.aws_security_groups.this.ids, 
                            data.aws_network_interfaces.this.ids) 

  work_list             = toset(flatten([
    for index, item in local.data_sources : [
        for key, value in var.tags : {
            block       = "${item}-${key}"
            resource_id = item
            tag_key     = key
            tag_value   = value
            }]]))
}

####################################################################################################
# Add tags to instances, volumes, etc
####################################################################################################
resource "aws_ec2_tag" "this" {
  for_each              = {
    for k, v in local.work_list :
    v.block => v }

  resource_id           = each.value.resource_id
  key                   = each.value.tag_key
  value                 = each.value.tag_value
}