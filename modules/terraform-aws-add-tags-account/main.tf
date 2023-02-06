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
 
  endpoint_id           = { for key, value in jsondecode(data.external.endpoint_ids.result.output) : value => value }

  vpc_id                = { for key, value in jsondecode(data.external.vpc_ids.result.output) : value => value }

  subnet_id             = { for key, value in jsondecode(data.external.subnet_ids.result.output) : value => value }

  sg_id                 = { for key, value in jsondecode(data.external.sg_ids.result.output) : value => value }

  rt_id                 = { for key, value in jsondecode(data.external.rt_ids.result.output) : value => value }

  vpcx_id               = { for key, value in jsondecode(data.external.vpcx_ids.result.output) : value => value }

  igw_id                = { for key, value in jsondecode(data.external.igw_ids.result.output) : value => value }

  nacl_id               = { for key, value in jsondecode(data.external.nacl_ids.result.output) : value => value }

  ecr_id                = { for key, value in jsondecode(data.external.ecr_ids.result.output) : value => value }

  alarm_arn             = { for key, value in jsondecode(data.external.alarm_arns.result.output) : value => value }

  role_name             = { for key, value in jsondecode(data.external.role_names.result.output) : value => value }

  policy_arn            = { for key, value in jsondecode(data.external.policy_arns.result.output) : value => value }
  
  user_name             = { for key, value in jsondecode(data.external.user_names.result.output) : value => value }

  ami_id                = { for key, value in jsondecode(data.external.ami_ids.result.output) : value => value }

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


work_list3          = toset(flatten([
    for index, item in jsondecode(data.external.asg_names.result.output) : [
        for key, value in var.tags : {
            block       = "${item}-${key}"
            ResourceId  = item        
            Key         = key
            Value       = value
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

####################################################################
# Add tags to ASGs
####################################################################
resource "null_resource" "asg_names" {
  for_each              = {
    for k, v in local.work_list3 :
    v.block => v }
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws autoscaling create-or-update-tags --cli-input-json '{"Tags": [{"ResourceId": "${each.value.ResourceId}","ResourceType": "auto-scaling-group", "Key": "${each.value.Key}", "Value": "${each.value.Value}", "PropagateAtLaunch": true }]}'
    EOT
  }
}

####################################################################
# Add tags to endpoints
####################################################################
resource "null_resource" "endpoints" {
  for_each              = local.endpoint_id
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws ec2 create-tags --cli-input-json '{"Resources": ["${each.value}"], "Tags": ${local.tag_json}}'
    EOT
  }
}

####################################################################
# Add tags to vpcs
####################################################################
resource "null_resource" "vpcs" {
  for_each              = local.vpc_id
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws ec2 create-tags --cli-input-json '{"Resources": ["${each.value}"], "Tags": ${local.tag_json}}'
    EOT
  }
}

####################################################################
# Add tags to subnets
####################################################################
resource "null_resource" "subnets" {
  for_each              = local.subnet_id
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws ec2 create-tags --cli-input-json '{"Resources": ["${each.value}"], "Tags": ${local.tag_json}}'
    EOT
  }
}

####################################################################
# Add tags to security groups
####################################################################
resource "null_resource" "security_groups" {
  for_each              = local.sg_id
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws ec2 create-tags --cli-input-json '{"Resources": ["${each.value}"], "Tags": ${local.tag_json}}'
    EOT
  }
}


####################################################################
# Add tags to route tables
####################################################################
resource "null_resource" "route_tables" {
  for_each              = local.rt_id
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws ec2 create-tags --cli-input-json '{"Resources": ["${each.value}"], "Tags": ${local.tag_json}}'
    EOT
  }
}

####################################################################
# Add tags to vpc peering connections
####################################################################
resource "null_resource" "vpcx" {
  for_each              = local.vpcx_id
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws ec2 create-tags --cli-input-json '{"Resources": ["${each.value}"], "Tags": ${local.tag_json}}'
    EOT
  }
}

####################################################################
# Add tags to igws
####################################################################
resource "null_resource" "igw" {
  for_each              = local.igw_id
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws ec2 create-tags --cli-input-json '{"Resources": ["${each.value}"], "Tags": ${local.tag_json}}'
    EOT
  }
}

####################################################################
# Add tags to nacls
####################################################################
resource "null_resource" "nacl" {
  for_each              = local.nacl_id
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws ec2 create-tags --cli-input-json '{"Resources": ["${each.value}"], "Tags": ${local.tag_json}}'
    EOT
  }
}

####################################################################
# Add tags to ecr repos
####################################################################
resource "null_resource" "ecr" {
  for_each              = local.ecr_id
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws ecr tag-resource --cli-input-json '{"resourceArn": "${each.value}", "tags": ${local.tag_json}}'
    EOT
  }
}

####################################################################
# Add tags to cloudwatch alarms
####################################################################
resource "null_resource" "alarms" {
  for_each              = local.alarm_arn
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws cloudwatch tag-resource --cli-input-json '{"ResourceARN": "${each.value}", "Tags": ${local.tag_json}}'
    EOT
  }
}

####################################################################
# Add tags to iam roles
####################################################################
resource "null_resource" "roles" {
  for_each              = local.role_name
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws iam tag-role --cli-input-json '{"RoleName": "${each.value}", "Tags": ${local.tag_json}}'
    EOT
  }
}

####################################################################
# Add tags to iam policies
####################################################################
resource "null_resource" "policies" {
  for_each              = local.policy_arn
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws iam tag-policy --cli-input-json '{"PolicyArn": "${each.value}", "Tags": ${local.tag_json}}'
    EOT
  }
}

####################################################################
# Add tags to iam users
####################################################################
resource "null_resource" "users" {
  for_each              = local.user_name
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws iam tag-user --cli-input-json '{"UserName": "${each.value}", "Tags": ${local.tag_json}}'
    EOT
  }
}

####################################################################
# Add tags to vgws
####################################################################
resource "null_resource" "amis" {
  for_each              = local.ami_id
    
    provisioner "local-exec" {
    command             = <<-EOT
      aws ec2 create-tags --cli-input-json '{"Resources": ["${each.value}"], "Tags": ${local.tag_json}}'
    EOT
  }
}
