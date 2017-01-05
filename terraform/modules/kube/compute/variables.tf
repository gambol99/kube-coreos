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
  default     = "595879546273"
}
variable "key_name" {
  description = "The name of the AWS ssh keypair to use for the boxes"
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
variable "etcd_memberlist" {
  description = "The URL for the etcd cluster members, i.e. node=0=https://127.0.0.1:2380,..."
}
variable "flannel_memberlist" {
  description = "The URL for the flannel etcd cluster members, i.e. https://127.0.0.1:2379,..."
}
variable "kubeapi_dns" {
  description = "The dns name of the internal kubernetes api elb"
}
variable "enable_calico" {
  description = "Whether the calico should be enabled on the compute layer"
}
variable "compute_labels" {
  description = "A map of keypairs which are added as node labels to the compute nodes"
  type        = "map"
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
## COMPUTE RELATED ##
#
variable "compute_flavor" {
  description = "The AWS instance type to use for the compute nodes"
}
variable "compute_asg_grace_period" {
  description = "The grace period between rebuild in the compute auto-scaling group"
}
variable "compute_asg_max" {
  description = "The maximum number of machines in the compute auto-scaling group"
}
variable "compute_asg_min" {
  description = "The minimum number of machines in the compute auto-scaling group"
}
variable "compute_root_volume" {
  description = "The partition size of the docker partition for the compute nodes"
}
variable "compute_docker_volume_type" {
  description = "The /var/lib/docker partition for the compute node ebs type"
}
variable "compute_docker_volume" {
  description = "The size of the /var/lib/docker partition for the compute nodes"
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
