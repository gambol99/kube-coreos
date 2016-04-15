#
## Generic Inputs
#
variable "environment" {
  description = "The environment i.e. dev, prod, stage etc"
}
variable "dns_zone_name" {
  description = "The route53 domain associated to the environment"
  default     = "dsp.io"
}
variable "kms_master_id" {
  description = "The AWS KMS id this environment is using"
}
variable "secrets_bucket_name" {
  description = "The name of the s3 bucket which is holding the secrets"
}
variable "coreos_image" {
  description = "The CoreOS image ami we should be using"
  default     = "ami-2cf84d5f"
}


#
## Vault Inputs
#
variable "vault_release_version" {
  description = "The distribution version of Vault we should use"
  default     = "0.4.1"
}
variable "vault_release_md5" {
  description = "The distribution md5 sum of the distribution we are downloading"
  default     = "0.4.1"
}
variable "vault_root_volume_size" {
  description = "The size of the vault root partition"
  default     = "24"
}
variable "vault_asg_max" {
  description = "The maximum number of machines in the vault auto-scaling group"
  default     = "100"
}
variable "vault_asg_min" {
  description = "The minimum number of machines in the vault auto-scaling group"
  default     = "3"
}
