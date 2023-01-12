####################################################################
# Transform data into list of objects containing tag
# variables from env.hcl and .....
####################################################################
locals {
  bucket_data           = { for key, value in data.aws_s3_bucket.this : key => value.id }

  eip_data              = { for key, value in data.aws_eip.this : key => value.id }

  elb_name              = { for key, value in jsondecode(data.external.elb_names.result.output) : value => value }

  alb_arn               = { for key, value in jsondecode(data.external.elbv2_arns.result.output) : value => value }

  sns_arn               = { for key, value in jsondecode(data.external.sns_arns.result.output) : value => value }

  db_names              = { for key, value in jsondecode(data.external.db_names.result.output) : value => value }

  acm_arn               = { for key, value in jsondecode(data.external.acm_arns.result.output) : value => value }

  lambda_arn            = { for key, value in jsondecode(data.external.lambda_arns.result.output) : value => value }

  kms_id                = { for key, value in jsondecode(data.external.kms_ids.result.output) : value => value }

  vgw_id                = { for key, value in jsondecode(data.external.vgw_ids.result.output) : value => value }

  volume_id             = { for key, value in jsondecode(data.external.volume_ids.result.output) : value => value }

  instance_id           = { for key, value in jsondecode(data.external.instance_ids.result.output) : value => value }

  eks_name              = { for key, value in jsondecode(data.external.eks_names.result.output) : value => value }

  ngw_id                = { for key, value in jsondecode(data.external.ngw_ids.result.output) : value => value }

  sqs_queue             = { for key, value in jsondecode(data.external.sqs_queues.result.output) : value => value }

  snapshot_arn          = { for key, value in jsondecode(data.external.snapshot_arns.result.output) : value => value }

  tag_json              = jsonencode([
    for key, value in var.tags : {
      Key               = key
      Value             = value
  }])

# Different JSON format required for Lambda

  tag_lambda_json       = jsonencode(var.tags)

# Different JSON format required for kms

  tag_kms_json          = jsonencode([
    for key, value in var.tags : {
      TagKey            = key
      TagValue          = value
  }])
  
  work_list1            = toset(flatten([
    for index, item in local.eip_data : [
        for key, value in var.tags : {
            block       = "${item}-${key}"
            resource_id = item
            tag_key     = key
            tag_value   = value
            }]]))

    work_list2          = toset(flatten([
    for index, item in jsondecode(data.external.log_arns.result.output) : [
        for key, value in var.tags : {
            block       = "${item}-${key}"
            resource_id = item        
            tag_key     = key
            tag_value   = value
            }]]))
}

####################################################################
# Add tags to EIPs
####################################################################
resource "aws_ec2_tag" "this" {
  for_each              = {
    for k, v in local.work_list1 :
    v.block => v }

  resource_id           = each.value.resource_id
  key                   = each.value.tag_key
  value                 = each.value.tag_value
}

####################################################################
# Add tags to s3 buckets
####################################################################
resource "null_resource" "s3" {
  for_each              = local.bucket_data 
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws s3api put-bucket-tagging --bucket ${each.value} --tagging '{"TagSet": ${local.tag_json}}'
    EOT
  }
}

####################################################################
# Add tags to Classic ELBs
####################################################################
resource "null_resource" "elb" {
  for_each              = local.elb_name
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws elb add-tags --cli-input-json '{"LoadBalancerNames": ["${each.value}"], "Tags": ${local.tag_json}}'
    EOT
  }
}

####################################################################
# Add tags to ELBs
####################################################################
resource "null_resource" "elbv2" {
  for_each              = local.alb_arn
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws elbv2 add-tags --cli-input-json '{"ResourceArns": ["${each.value}"], "Tags": ${local.tag_json}}'
    EOT
  }
}

####################################################################
# Add tags to flow logs
####################################################################
resource "aws_ec2_tag" "flow-logs" {
  for_each              = {
    for k, v in local.work_list2 :
    v.block => v }

  resource_id           = each.value.resource_id
  key                   = each.value.tag_key
  value                 = each.value.tag_value
}

####################################################################
# Add tags to sns topics
####################################################################
resource "null_resource" "sns" {
  for_each              = local.sns_arn
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws sns tag-resource --cli-input-json '{"ResourceArn": "${each.value}", "Tags": ${local.tag_json}}'
    EOT
  }
}

####################################################################
# Add tags to dynamodb tables
####################################################################
resource "null_resource" "db_names" {
  for_each              = local.db_names
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws dynamodb tag-resource --cli-input-json '{"ResourceArn": "arn:aws:dynamodb:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:table/${each.value}", "Tags": ${local.tag_json}}'
    EOT
  }
}

####################################################################
# Add tags to certs in acm
####################################################################
resource "null_resource" "acm" {
  for_each              = local.acm_arn
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws acm add-tags-to-certificate --cli-input-json '{"CertificateArn": "${each.value}", "Tags": ${local.tag_json}}'
    EOT
  }
}

####################################################################
# Add tags to lambdas
####################################################################
resource "null_resource" "lambda" {
  for_each              = local.lambda_arn
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws lambda tag-resource --cli-input-json '{"Resource": "${each.value}", "Tags": ${local.tag_lambda_json}}'
    EOT
  }
}

####################################################################
# Add tags to kms keys
####################################################################
resource "null_resource" "kms" {
  for_each              = {
    for key, value in data.aws_kms_key.this : key => value 
    if value.key_manager == "CUSTOMER"
  }
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws kms tag-resource --cli-input-json '{"KeyId": "${each.value.id}", "Tags": ${local.tag_kms_json}}'
    EOT
  }
}

####################################################################
# Add tags to vgws
####################################################################
resource "null_resource" "vgws" {
  for_each              = local.vgw_id
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws ec2 create-tags --cli-input-json '{"Resources": ["${each.value}"], "Tags": ${local.tag_json}}'
    EOT
  }
}

####################################################################
# Add tags to volumes - this adds to all volumes, not just attached
####################################################################
resource "null_resource" "volumes" {
  for_each              = local.volume_id
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws ec2 create-tags --cli-input-json '{"Resources": ["${each.value}"], "Tags": ${local.tag_json}}'
    EOT
  }
}

####################################################################
# Add tags to instances - this adds to all ecs2s, not just attached
####################################################################
resource "null_resource" "instances" {
  for_each              = local.instance_id
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws ec2 create-tags --cli-input-json '{"Resources": ["${each.value}"], "Tags": ${local.tag_json}}'
    EOT
  }
}

####################################################################
# Add tags to all eks clusters
####################################################################
resource "null_resource" "eks" {
  for_each              = local.eks_name
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws eks tag-resource --cli-input-json '{"resourceArn": "arn:aws:eks:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:cluster/${each.value}", "tags": ${local.tag_lambda_json}}'
    EOT
  }
}

####################################################################
# Add tags to vgws
####################################################################
resource "null_resource" "ngws" {
  for_each              = local.ngw_id
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws ec2 create-tags --cli-input-json '{"Resources": ["${each.value}"], "Tags": ${local.tag_json}}'
    EOT
  }
}

####################################################################
# Add tags to sqs_queues
####################################################################
resource "null_resource" "sqs_queues" {
  for_each              = local.sqs_queue
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws sqs tag-queue --cli-input-json '{"QueueUrl": "${each.value}", "Tags": ${local.tag_lambda_json}}'
    EOT
  }
}

####################################################################
# Add tags to rds snapshots
####################################################################
resource "null_resource" "db_snapshots" {
  for_each              = local.snapshot_arn
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws rds add-tags-to-resource --cli-input-json '{"ResourceName": "${each.value}", "Tags": ${local.tag_json}}'
    EOT
  }
}
