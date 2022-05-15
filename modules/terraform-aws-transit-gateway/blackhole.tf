################################################################################
# Blackhole route
################################################################################

resource "aws_ec2_transit_gateway_route" "blackhole" {
  count = var.create_tgw ? 1 : 0

  destination_cidr_block         = "0.0.0.0/0"
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway.this[0].association_default_route_table_id
}