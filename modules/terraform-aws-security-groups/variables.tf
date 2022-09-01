###########################################################################
# Security group variable
###########################################################################

variable "vpc_id" {
  type        = any
  default     = {}  
  description = "VPC ID for security rule"
}

variable "name" {
  type        = any
  default     = {}  
  description = "Name of security group"
}

variable "description" {
  type        = any
  default     = {}  
  description = "Description of security group"
}

###########################################################################
# Security group rule variable
###########################################################################

variable "ingress_with_source_security_group_id" {
  type        = any
  default     = {}
  description = <<EOT
Use this format:

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
EOT
}

variable "egress_with_source_security_group_id" {
  type        = any
  default     = {}
  description = <<EOT
Use this format:

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
EOT
}

variable "ingress_with_cidr_blocks" {
  type        = any
  default     = {}
  description = <<EOT
Use this format:

ingress_with_cidr_blocks = {
  "allow ping inbound from all rfc 1918" = {
    cidr_blocks                          = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    from_port                            = -1
    to_port                              = -1
    protocol                             = "icmp"
  }}
EOT  
}

variable "egress_with_cidr_blocks" {
  type        = any
  default     = {} 
  description = <<EOT
Use this format:

egress_with_cidr_blocks = {
  "allow ping outbound to all rfc 1918" = {
    cidr_blocks                         = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    from_port                           = -1
    to_port                             = -1
    protocol                            = "icmp"
  }}
EOT    
}