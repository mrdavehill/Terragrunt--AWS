####################################################################
# Create a list of all buckets, transform in locals and use to obtain bucket IDs
####################################################################
data "external" "bucket_names" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws s3api list-buckets | grep -v 'west-2' | grep -v 'us'", top = "Buckets", next = "| .Name' | grep -v 'null"})]
}

locals {
  bucket_names_list = {
    for key, value in jsondecode(data.external.bucket_names.result.output) : value => value
  }
}

data "aws_s3_bucket" "this" {
  for_each = local.bucket_names_list
  bucket   = each.value
}

####################################################################
# Create list of all public IPs, transform in locals and use to list all EIPs
####################################################################
data "external" "public_ips" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws ec2 describe-addresses", top = "Addresses", next = "| .PublicIp"})]
}

locals {
  public_ips_list = {
    for key, value in jsondecode(data.external.public_ips.result.output) : value => value
  }
}

data "aws_eip" "this" {
  for_each  = local.public_ips_list
  public_ip = each.value
}

####################################################################
# Create list of all classic lbs
####################################################################
data "external" "elb_names" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws elb describe-load-balancers", top = "LoadBalancerDescriptions", next = "| .LoadBalancerName"})]
}

####################################################################
# Create list of all elbsv2 lb arns
####################################################################
data "external" "elbv2_arns" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws elbv2 describe-load-balancers", top = "LoadBalancers", next = "| .LoadBalancerArn"})]
}

####################################################################
# Create list of flow log ARNs
####################################################################
data "external" "log_arns" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws ec2 describe-flow-logs", top = "FlowLogs", next = "| .FlowLogId"})]
}

####################################################################
# Create list of all sns topics
####################################################################
data "external" "sns_arns" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws sns list-topics", top = "Topics", next = "| .TopicArn"})]
}

####################################################################
# Create list of all dynamodb tables, and get account number and 
# region to create arns
####################################################################
data "external" "db_names" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws dynamodb list-tables", top = "TableNames", next = ""})]
}

data "aws_caller_identity" "this" {}

data "aws_region" "this" {}

####################################################################
# Create list of all certificate arns
####################################################################
data "external" "acm_arns" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws acm list-certificates", top = "CertificateSummaryList", next = "| .CertificateArn"})]
}

####################################################################
# Create list of all lambda arns
####################################################################
data "external" "lambda_arns" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws lambda list-functions", top = "Functions", next = "| .FunctionArn"})]
}

####################################################################
# Create list of all kms ids
####################################################################
data "external" "kms_ids" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws kms list-keys", top = "Keys", next = "| .KeyId"})]
}


locals {
  kms_ids_list = {
    for key, value in jsondecode(data.external.kms_ids.result.output) : value => value
  }
}

data "aws_kms_key" "this" {
  for_each = local.kms_ids_list
  key_id   = each.value
}

####################################################################
# Create list of all sqs queues
####################################################################
data "external" "sqs_queues" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws sqs list-queues", top = "QueueUrls", next = ""})]
}

####################################################################
# Create list of all vgws
####################################################################
data "external" "vgw_ids" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws directconnect describe-virtual-gateways", top = "virtualGateways", next = "| .virtualGatewayId"})]
}

####################################################################
# Create list of all volumes at account level
####################################################################
data "external" "volume_ids" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws ec2 describe-volumes", top = "Volumes", next = "| .VolumeId"})]
}

####################################################################
# Create list of all ec2s at account level
####################################################################
data "external" "instance_ids" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws ec2 describe-instances", top = "Reservations", next = " .Instances[].InstanceId"})]
}

####################################################################
# Create list of all eks clusters in the account
####################################################################
data "external" "eks_names" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws eks list-clusters", top = "clusters", next = ""})]
}

####################################################################
# Create list of all nat gateways in the account
####################################################################
data "external" "ngw_ids" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws ec2 describe-nat-gateways", top = "NatGateways", next = "| .NatGatewayId"})]
}

####################################################################
# Create list of all rds snapshots
####################################################################
data "external" "snapshot_arns" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws rds describe-db-snapshots", top = "DBSnapshots", next = "| .DBSnapshotArn"})]
}

####################################################################
# Create list of all ASG's
####################################################################
data "external" "asg_names" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws autoscaling describe-auto-scaling-groups", top = "AutoScalingGroups", next = "| .AutoScalingGroupName"})]
}

####################################################################
# Create list of all vpc endpoints
####################################################################
data "external" "endpoint_ids" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws ec2 describe-vpc-endpoints", top = "VpcEndpoints", next = "| .VpcEndpointId"})]
}

####################################################################
# Create list of all vpcs
####################################################################
data "external" "vpc_ids" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws ec2 describe-vpcs", top = "Vpcs", next = "| .VpcId"})]
}

####################################################################
# Create list of all subnets
####################################################################
data "external" "subnet_ids" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws ec2 describe-subnets", top = "Subnets", next = "| .SubnetId"})]
}

####################################################################
# Create list of all security groups
####################################################################
data "external" "sg_ids" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws ec2 describe-security-groups", top = "SecurityGroups", next = "| .GroupId"})]
}

####################################################################
# Create list of all route-tables
####################################################################
data "external" "rt_ids" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws ec2 describe-route-tables", top = "RouteTables", next = "| .RouteTableId"})]
}

####################################################################
# Create list of all vpc peering connections
####################################################################
data "external" "vpcx_ids" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws ec2 describe-vpc-peering-connections", top = "VpcPeeringConnections", next = "| .VpcPeeringConnectionId"})]
}

####################################################################
# Create list of all igws
####################################################################
data "external" "igw_ids" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws ec2 describe-internet-gateways", top = "InternetGateways", next = "| .InternetGatewayId"})]
}

####################################################################
# Create list of all nacls
####################################################################
data "external" "nacl_ids" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws ec2 describe-network-acls", top = "NetworkAcls", next = "| .NetworkAclId"})]
}

####################################################################
# Create list of all ecr repos
####################################################################
data "external" "ecr_ids" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws ecr describe-repositories", top = "repositories", next = "| .repositoryArn"})]
}

####################################################################
# Create list of cloudwatch alarms
####################################################################
data "external" "alarm_arns" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws cloudwatch describe-alarms", top = "MetricAlarms", next = "| .AlarmArn"})]
}

####################################################################
# Create list of iam roles
####################################################################
data "external" "role_names" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws iam list-roles", top = "Roles", next = "| .RoleName' | grep -v 'AWSRes"})]
}

####################################################################
# Create list of iam policies
####################################################################
data "external" "policy_arns" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws iam list-policies", top = "Policies", next = "| .Arn' | grep -v 'arn:aws:iam::aws:policy"})]
}

####################################################################
# Create list of iam users
####################################################################
data "external" "user_names" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws iam list-users", top = "Users", next = "| .UserName"})]
}


####################################################################
# Create list of amis
####################################################################
data "external" "ami_ids" {
  program    = [
    "bash",
    "-c", 
    templatefile("cli.tftpl", {input_string = "aws ec2 describe-images --owners ${data.aws_caller_identity.this.account_id}", top = "Images", next = "| .ImageId"})]
}
