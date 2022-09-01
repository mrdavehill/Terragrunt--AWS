###########################################################################
# Module outputs
###########################################################################

output "ingress_src_grp_id" {
    value = local.ingress_src_grp_id
}

output "egress_src_grp_id" {
    value = local.egress_src_grp_id
}

output "ingress_cidr" {
    value = local.ingress_cidr
}

output "egress_cidr" {
    value = local.egress_cidr
}

output "ws_security_group_arn" {
   value = aws_security_group.this.arn
}

output "ws_security_group_description" {
   value = aws_security_group.this.description
}

output "ws_security_group_id" {
   value = aws_security_group.this.id
}

output "ws_security_group_name" {
   value = aws_security_group.this.name
}

output "ws_security_group_owner_id" {
   value = aws_security_group.this.owner_id
}

output "ws_security_group_tags_all" {
   value = aws_security_group.this.tags_all
}

output "ws_security_group_revoke_rules_on_delete" {
   value = aws_security_group.this.revoke_rules_on_delete
}

###########################################################################
# Demo/test outputs
###########################################################################

output "local_ingress_rule" {
    value = aws_security_group_rule.ingress_with_source_security_group_id_local
}

output "peer_ingress_rule" {
    value = aws_security_group_rule.ingress_with_source_security_group_id_peer
}

output "scratch_output" {
    value = local.scratch_local
}