#
## Generic Inputs
#
variable "platform" {
  description = "The name of the platform"
  default     = "kube"
}
variable "environment" {
  description = "The environment i.e. dev, prod, stage etc"
}
variable "dns_zone_name" {
  description = "The route53 domain associated to the environment"
  default     = "dsp.io"
}
variable "aws_account" {
  description = "The account id or alias, required for kubernetes manifests"
}
variable "kms_master_id" {
  description = "The AWS KMS id this environment is using"
}
variable "secrets_bucket_name" {
  description = "The name of the s3 bucket which is holding the secrets"
}
variable "coreos_image" {
  description = "The CoreOS image ami we should be using"
  default     = "ami-7a46d809"
}
variable "flannel_cidr" {
  description = "The flannel overlay network cidr"
  default     = "10.10.0.0/16"
}
variable "etcd_discovery_url" {
  description = "The url to download the etcd-discovery binary"
  default     = "https://github.com/gambol99/etcd-discovery/releases/download/latest/etcd-discovery_v0.0.1_linux_x86_64.gz"
}
variable "etcd_discovery_md5" {
  description = "The md5 of the etcd-discovery binary"
  default     = "bd8e7d30a365efee56a52666b016b75c"
}
variable "kubernetes_image" {
  description = "The docker kubernetes image we are using"
  default     = "quay.io/coreos/hyperkube"
}
variable "kubernetes_version" {
  description = "The version / tag version of the kubernetes release"
  default     = "v1.3.0_coreos.1"
}
variable "kubernetes_service_range" {
  description = "The CIDR of the kubernetes service address space"
  default     = "10.200.0.0/16"
}
variable "kubernetes_dns_service_address" {
  description = "The Kube DNS service address, must be within the service range"
  default     = "10.200.0.10"
}
variable "ssh_access_list" {
  description = "A comma separated list of ip addresses to permit external ssh access"
}
variable "kubeapi_access_list" {
  description = "A comma separated list of ip addresses to permit external kubeapi access"
}
variable "terraform_bucket_name" {
  description = "The name of the bucket used to hold the terraform state"
}

#
## AWS PROVIDER ##
#
variable "aws_access_key" {
  description = "The AWS Access Key for API access"
}
variable "aws_region" {
  description = "The AWS Region we are building the cluster in"
}
variable "aws_secret_key" {
  description = "The AWS Secret Key for API access"
}

#
## AWS NETWORKING
#
variable "vpc_cidr" {
  description = "The CIDR of the VPC for this environment"
  default     = "10.100.0.0/16"
}
variable "compute_subnets" {
  description = "The compute subnets and the zone's they occupy"
  default = {
    "az0_cidr"  = "10.100.0.0/24"
    "az1_cidr"  = "10.100.1.0/24"
    "az2_cidr"  = "10.100.2.0/24"
    "az0_zone"  = "eu-west-1a"
    "az1_zone"  = "eu-west-1b"
    "az2_zone"  = "eu-west-1c"
  }
}
variable "secure_subnets" {
  description = "The secure subnets and the zone's they occupy"
  default = {
    "az0_cidr"  = "10.100.10.0/24"
    "az1_cidr"  = "10.100.11.0/24"
    "az2_cidr"  = "10.100.12.0/24"
    "az0_zone"  = "eu-west-1a"
    "az1_zone"  = "eu-west-1b"
    "az2_zone"  = "eu-west-1c"
  }
}

#
## COMPUTE RELATED ##
#
variable "compute_flavor" {
  description = "The AWS instance type to use for the compute nodes"
  default     = "t2.small"
}
variable "compute_root_volume_size" {
  description = "The root size of the compute nodes"
  default     = "32"
}
variable "compute_asg_grace_period" {
  description = "The grace period between rebuild in the compute auto-scaling group"
  default     = "10"
}
variable "compute_asg_max" {
  description = "The maximum number of machines in the compute auto-scaling group"
  default     = "100"
}
variable "compute_asg_min" {
  description = "The minimum number of machines in the compute auto-scaling group"
  default     = "3"
}
variable "compute_root_size" {
  description = "The partition size of the docker partition for the compute nodes"
  default     = "32"
}
variable "compute_docker_volume_type" {
  description = "The /var/lib/docker partition for the compute node ebs type"
  default     = "standard"
}
variable "compute_docker_volume_size" {
  description = "The size of the /var/lib/docker partition for the compute nodes"
  default     = "24"
}

#
## SECURE LAYER RELATED
#
variable "secure_flavor" {
  description = "The AWS instance type to use for the secure nodes"
  default     = "t2.small"
}
variable "secure_asg_max" {
  description = "The maximum amount of nodes in the secure auto-scaling cluster"
  default     = "4"
}
variable "secure_asg_min" {
  description = "The minimum amount of nodes in the secure auto-scaling group, should be at least 5 for dynamic updates to work"
  default     = "3"
}
variable "secure_root_volume_size" {
  description = "The size of the root partition of a secure node"
  default     = "24"
}
variable "secure_asg_grace_period" {
  description = "The grace period between rebuild in the secure auto-scaling group"
  default     = "180"
}

#
## SECURE LAYER RELATED ##
#
variable "secure_flavor" {
  description = "The AWS instance type to use for the secure nodes"
  default     = "t2.small"
}
variable "secure_asg_max" {
  description = "The maximum amount of nodes in the secure auto-scaling cluster"
  default     = "6"
}
variable "secure_asg_min" {
  description = "The minimum amount of nodes in the secure auto-scaling group, should be at least 5 for dynamic updates to work"
  default     = "5"
}
variable "secure_root_volume_size" {
  description = "The size of the root partition of a secure node"
  default     = "24"
}
variable "secure_etcd_root_volume_size" {
  description = "The size of the etcd data partition of a secure node"
  default     = "24"
}
variable "secure_asg_grace_period" {
  description = "The grace period between rebuild in the secure auto-scaling group"
  default     = "180"
}

#
## MISC RELATED ##
#
variable "kmsctl_release_md5" {
  description = "The md5 of the kmsctl release we are using"
  default     = "0a09bc94f065d32f11797ec2390f589e"
}
variable "kmsctl_release_url" {
  description = "The url for the kmsctl release we are using"
  default     = "https://github.com/gambol99/kmsctl/releases/download/v0.2.0/kmsctl_v0.2.0_linux_x86_64.gz"
}
