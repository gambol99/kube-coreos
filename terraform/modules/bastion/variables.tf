## Generic Inputs
variable "environment" {
  description = "The environment i.e. dev, prod, stage etc"
}
variable "kms_master_id" {
  description = "The AWS KMS id this environment is using"
}
variable "key_name" {
  description = "The name of the AWS keypair to use on the bastion"
}
variable "bastion_image" {
  description = "The CoreOS image AMI to use for the nodes"
}
variable "bastion_image_owner" {
  description = "The owner of the AMI to use, used by the filter"
}
variable "public_zone_name" {
  description = "The route53 domain associated to the environment"
}
variable "private_zone_name" {
  description = "The internal private domain for the environment"
}
variable "secrets_bucket_name" {
  description = "The name of the s3 bucket which is holding the secrets"
}
variable "bastion_flavor" {
  description = "The AWS instance type we should use for the bastion host"
  default     = "t2.small"
}
variable "bastion_count" {
  description = "The number of the instances in the bastion asg"
  default     = 1
}

#
## AWS PROVIDER
#
variable "aws_region" {
  description = "The AWS Region we are building the cluster in"
}

#
## AWS NETWORKING
#
variable "vpc_id" {
  description = "The VPC id of the platform"
}
variable "bastion_subnets" {
  description = "A list of subnet that the bastion should deploy into"
  type        = "list"
}
variable "bastion_sg" {
  description = "The AWS security group to use on with the bastion hosts"
}

## KUBERNETES ##
variable "kubernetes_image" {
  description = "The docker kubernetes image we are using"
}

## RELEASES ##
variable "kmsctl_release_md5" {
  description = "The md5 of the kmsctl release we are using"
  default     = "3d2a4a68a999cb67955f21eaed4127fb"
}
variable "kmsctl_release_url" {
  description = "The url for the kmsctl release we are using"
  default     = "https://github.com/gambol99/kmsctl/releases/download/v1.0.3/kmsctl-linux-amd64.gz"
}
variable "kmsctl_image" {
  description = "The kmsctl docker container image to use"
  default     = "quay.io/gambol99/kmsctl:v1.0.3"
}
