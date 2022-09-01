###########################################################################
# Variables for testing module
###########################################################################

name                           = "sg_prepod_firewall_trust"
description                    = "trust interface"
vpc_id                         = "vpc-xxxxxxxxxx"

ingress_with_source_security_group_id = {
  "ssh mgmt access" = {
      source_security_group_id = "sg-peerxxxxx01"
      from_port                = 22
      to_port                  = 22
      protocol                 = "ssh"
  },
  "https mgmt access" = {
      source_security_group_id = "sg-peerxxxxx02"
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
    }}

egress_with_source_security_group_id = {
  "squid proxy" = {
      source_security_group_id = "sg-peerxxxxx03"
      from_port                = 3128
      to_port                  = 3128
      protocol                 = "tcp"
  },
  "snmp to mgmt" = {
      source_security_group_id = "sg-peerxxxxx04"
      from_port                = 161
      to_port                  = 161
      protocol                 = "udp"
  }}

ingress_with_cidr_blocks = {
  "allow ping inbound from all rfc 1918" = {
    cidr_blocks                = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    from_port                  = -1
    to_port                    = -1
    protocol                   = "icmp"
  }}

egress_with_cidr_blocks = {
  "allow ping outbound to all rfc 1918" = {
    cidr_blocks                = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    from_port                  = -1
    to_port                    = -1
    protocol                   = "icmp"
  }}
