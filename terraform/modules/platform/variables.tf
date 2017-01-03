#
## Generic Inputs
#
variable "environment" {
  description = "The environment i.e. dev, prod, stage etc"
}
variable "public_zone_name" {
  description = "The route53 domain associated to the environment"
}
variable "private_zone_name" {
  description = "The internal route53 domain associated to the environment"
}
variable "kms_master_id" {
  description = "The AWS KMS id this environment is using"
}
variable "secrets_bucket_name" {
  description = "The name of the s3 bucket which is holding the secrets"
}
variable "ssh_access_list" {
  description = "A comma separated list of ip addresses to permit external ssh access"
  type        = "list"
}

#
## AWS PROVIDER ##
#
#variable "aws_shared_credentials_file" {
#  description = "The file containing the AWS credentials"
#  default     = "/root/.aws/credentials"
#}
#variable "aws_profile" {
#  description = "The AWS profile to use from within the credentials file"
#}
variable "aws_region" {
  description = "The AWS Region we are building the cluster in"
}

#
## AWS NETWORKING
#
variable "vpc_cidr" {
  description = "The CIDR of the VPC for this environment"
}
variable "secure_subnets" {
  description = "The secure subnets and the zone's they occupy"
  type        = "map"
}
variable "compute_subnets" {
  description = "The compute subnets and the zone's they occupy"
  type        = "map"
}
variable "elb_subnets" {
  description = "The ELB subnets and the zone's they occupy"
  type        = "map"
}
variable "nat_subnets" {
  description = "The nat subnets and the zone's they occupy"
  type        = "map"
}
variable "mgmt_subnets" {
  description = "The management subnets and the zone's they occupy"
  type        = "map"
}
