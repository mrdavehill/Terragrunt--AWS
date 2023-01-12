output "work_list1" {
  value = local.work_list1
}

output "work_list2" {
  value = local.work_list2
}

output "tags" {
  value = var.tags
}

output "s3" {
  value = data.external.bucket_names.result
}

output "s3_bucket_ids" {
  value = local.bucket_data
}

output "public_ips" {
  value = data.external.public_ips.result
}

output "public_ips_list" {
  value = local.public_ips_list
}

output "alb_arns" {
  value = data.external.elbv2_arns.result
}

output "sns_arns" {
  value = data.external.sns_arns.result.output
}

output "view_tags_json" {
  value = local.tag_json
}

output "log_arns" {
  value = data.external.log_arns.result
}

output "db_names" {
  value = data.external.db_names.result
}

output "acm_arns" {
  value = data.external.acm_arns.result
}

output "lambda_arns" {
  value = data.external.lambda_arns.result
}

output "kms_ids" {
  value = data.external.kms_ids.result
}

output "tag_lambda_json" {
  value = local.tag_lambda_json
}

output "tag_kms_json" {
  value = local.tag_kms_json
}

output "kms_list" {
  value = data.aws_kms_key.this
}

output "volume_ids" {
  value = data.external.volume_ids.result
}

output "instance_ids" {
  value = data.external.instance_ids.result
}

output "eks_names" {
  value = data.external.eks_names.result
}

output "ngw_ids" {
  value = data.external.ngw_ids.result
}

output "sqs_queues" {
  value = data.external.sqs_queues.result
}

output "db_snapshot_arns" {
  value = data.external.snapshot_arns.result
}
