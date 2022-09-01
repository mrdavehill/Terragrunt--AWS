###########################################################################
# Inject maps into locals
###########################################################################

locals {
    ingress_src_grp_id = {
      for k,v in var.ingress_with_source_security_group_id : k => v
    }
    egress_src_grp_id = {
      for k,v in var.egress_with_source_security_group_id : k => v
    }
    ingress_cidr = {
      for k,v in var.ingress_with_cidr_blocks : k => v
    }
    egress_cidr = {
      for k,v in var.egress_with_cidr_blocks : k => v
    }
    scratch_local     = {
      for k,v in var.ingress_with_source_security_group_id : k => { prot = v.protocol }
    }
}

###########################################################################
# Create security-group
###########################################################################

resource "aws_security_group" "this" {
  name                     = var.name
  description              = var.description
  vpc_id                   = var.vpc_id
}

###########################################################################
# Ingress - ingress_with_source_security_group_id
# Create both local and peer rules
###########################################################################

resource "aws_security_group_rule" "ingress_with_source_security_group_id_local" {
  for_each                 = local.ingress_src_grp_id
  security_group_id        = aws_security_group.this.id
  type                     = "ingress"
  source_security_group_id = each.value.source_security_group_id
  description              = "${each.key}-local"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
}

resource "aws_security_group_rule" "ingress_with_source_security_group_id_peer" {
  for_each                 = local.ingress_src_grp_id
  security_group_id        = each.value.source_security_group_id
  type                     = "egress"
  source_security_group_id = aws_security_group.this.id
  description              = "${each.key}-peer"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
}

###########################################################################
# Egress - egress_with_source_security_group_id
# Create both local and peer rules
###########################################################################

resource "aws_security_group_rule" "egress_with_source_security_group_id_local" {
  for_each                 = local.egress_src_grp_id
  security_group_id        = aws_security_group.this.id
  type                     = "egress"
  source_security_group_id = each.value.source_security_group_id
  description              = "${each.key}-local"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
}

resource "aws_security_group_rule" "egress_with_source_security_group_id_peer" {
  for_each                 = local.egress_src_grp_id
  security_group_id        = each.value.source_security_group_id 
  type                     = "ingress"
  source_security_group_id = aws_security_group.this.id
  description              = "${each.key}-peer"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
}

###########################################################################
# Ingress - ingress_with_cidr_blocks
###########################################################################

resource "aws_security_group_rule" "ingress_with_cidr_blocks" {
  for_each                 = local.ingress_cidr
  security_group_id        = aws_security_group.this.id
  type                     = "ingress"
  cidr_blocks              = each.value.cidr_blocks
  description              = "${each.key}-local"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
}

###########################################################################
# Ingress - egress_with_cidr_blocks
###########################################################################

resource "aws_security_group_rule" "egress_with_cidr_blocks" {
  for_each                 = local.egress_cidr
  security_group_id        = aws_security_group.this.id
  type                     = "egress"
  cidr_blocks              = each.value.cidr_blocks
  description              = "${each.key}-local"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
}