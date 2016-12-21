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
variable "coreos_image" {
  description = "The CoreOS image ami we should be using"
}
variable "coreos_image_owner" {
  description = "The owner of the AMI to use, used by the filter"
}
variable "key_name" {
  description = "The name of the AWS ssh keypair to use for the boxes"
}
variable "flannel_cidr" {
  description = "The flannel overlay network cidr"
}
variable "kubernetes_image" {
  description = "The docker kubernetes image we are using"
}
variable "public_zone" {
  description = "The zone host ID of the route53 hosted domain"
}
variable "private_zone" {
  description = "The zone host ID of the internal route53 hosted domain"
}

#
## AWS PROVIDER
#
variable "aws_shared_credentials_file" {
  description = "The file containing the AWS credentials"
  default     = "/root/.aws/credentials"
}
variable "aws_profile" {
  description = "The AWS profile to use from within the credentials file"
  default     = "personal"
}
variable "aws_region" {
  description = "The AWS Region we are building the cluster in"
  default     = "eu-west-1"
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
variable "nat_subnets" {
  description = "A list of the nat subnets id's"
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
variable "nat_sg" {
  description = "The AWS security group id for the nat security group"
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
variable "secure_nodes" {
  description = "A list of the secure nodes hostnames of ip addresses"
  type        = "map"
}
variable "secure_nodes_info" {
  description = "The secure nodes detail map, container zones and subnets"
  type        = "map"
}
variable "secure_flavor" {
  description = "The AWS instance type to use for the secure nodes"
}
variable "secure_root_volume" {
  description = "The size of the root partition of a secure node"
}
variable "secure_data_volume" {
  description = "The size of the etcd data partition of a secure node"
}
variable "secure_data_encrypted" {
  description = "Indicates if the data volume for etcd should be encrypted"
}
variable "secure_docker_volume" {
  description = "The size in gigabytes for the docker volume partition"
}
variable "secure_asg_grace_period" {
  description = "The grace period between rebuild in the secure auto-scaling group"
}
variable "kubeapi_internal_dns" {
  description = "The dns name of the internal kubernetes api elb"
}
variable "etcd_dns" {
  description = "The dns name of the internal etcd elb"
}

#
## MISC RELATED ##
#
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
variable "kube_auth_image" {
  description = "The docker container image for kube auth"
  default     = "quay.io/gambol99/kube-auth:v0.5.0"
}
variable "smilodon_release_url" {
  description = "The release URL for the smilodon binary"
  default     = "https://github.com/UKHomeOffice/smilodon/releases/download/v0.0.4/smilodon-0.0.4-linux-amd64"
}
variable "smilodon_release_md5" {
  description = "The release MD5 for the smilodon binary"
  default     = "071d32e53fdb53fa17c7bbe03744fdf6"
}
