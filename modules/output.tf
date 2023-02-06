output "aws_subnets" {
  value = data.aws_subnets.this
}

output "aws_instances" {
  value = data.aws_instances.this
}

output "work_list" {
  value = local.work_list
}

output "data_sources" {
  value = local.data_sources
}

output "tags" {
  value = var.tags
}

output "aws_ebs_volumes" {
  value = data.aws_ebs_volumes.this.ids
}

output "aws_nat_gateways" {
  value = data.aws_nat_gateways.this.ids
}
