## Generic Inputs
variable "environment" {
  description = "The environment i.e. dev, prod, stage etc"
}
variable "dns_zone_name" {
  description = "The route53 domain associated to the environment"
}
variable "kms_master_id" {
  description = "The AWS KMS id this environment is using"
}
variable "secrets_bucket_name" {
  description = "The name of the s3 bucket which is holding the secrets"
}
variable "coreos_image" {
  description = "The CoreOS image AMI to use for the nodes"
}
variable "coreos_image_owner" {
  description = "The owner of the AMI to use, used by the filter"
}
variable "bastion_subnets" {
  description = "A list of subnet that the bastion should deploy into"
}
variable "sshd_config" {
  description = "The content of the openssh sshd daemon"
  default     = ""
}
variable "authorized_keys" {
  description = "The content containing the authorized key for users"
  default     = ""
}

## KUBERNETES ##
variable "kubernetes_image" {
  description = "The docker kubernetes image we are using"
  default     = "quay.io/coreos/hyperkube"
}
variable "kubernetes_version" {
  description = "The version / tag version of the kubernetes release"
  default     = "v1.4.7_coreos.0"
}
