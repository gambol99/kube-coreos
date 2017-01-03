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
variable "public_zone" {
  description = "The zone host ID of the route53 hosted domain"
}
variable "private_zone" {
  description = "The zone host ID of the route53 hosted domain"
}
variable "kubeapi_access_list" {
  description = "A list of ip addresses which are permited to access the API"
  default     = [ "0.0.0.0/0" ]
}
variable "kubeapi_external_elb" {
  description = "Indicates if we should have an external kubernetes api"
  default     = false
}
variable "kubeapi_internal_dns" {
  description = "The dns name of the internal kubernetes api elb"
  default     = "kube"
}
variable "kubeapi_dns" {
  description = "The dns / hostname of the external kubernetes api"
}

#
## AWS PROVIDER
#
#variable "aws_shared_credentials_file" {
#  description = "The file containing the AWS credentials"
#  default     = "/root/.aws/credentials"
#}
#variable "aws_profile" {
#  description = "The AWS profile to use from within the credentials file"
#  default     = "terraform-bug"
#}
variable "aws_region" {
  description = "The AWS Region we are building the cluster in"
}

#
## AWS NETWORKING
#
variable "vpc_id" {
  description = "The VPC id of the platform"
}
variable "compute_subnets" {
  description = "A list of the compute subnets id's"
  type        = "list"
}
variable "secure_subnets" {
  description = "A list of the secure subnets id's"
  type        = "list"
}
variable "elb_subnets" {
  description = "A list of the elb subnets id's"
  type        = "list"
}
variable "mgmt_subnets" {
  description = "A list of the management subnets id's"
  type        = "list"
}
variable "compute_sg" {
  description = "The AWS security group id for the compute security group"
}
variable "secure_sg" {
  description = "The AWS security group id for the secure security group"
}
variable "elb_sg" {
  description = "The AWS security group id for the elb security group"
}
variable "mgmt_sg" {
  description = "The AWS security group id for the mgmt security group"
}

#
## SECURE LAYER RELATED ##
#
variable "secure_asg" {
  description = "The AWS auto-scaling group id used to attach the ELB to"
}
