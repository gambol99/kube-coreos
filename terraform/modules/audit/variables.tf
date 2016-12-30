
## AWS PROVIDER ##
variable "aws_shared_credentials_file" {
  description = "The file containing the AWS credentials"
  default     = "/root/.aws/credentials"
}
variable "aws_profile" {
  description = "The AWS profile to use from within the credentials file"
  default     = "default"
}
variable "aws_region" {
  description = "The AWS Region we are building the cluster in"
  default     = "eu-west-1"
}
variable "audit_bucket" {
  description = "The name of the s3 bucket the cloudtail logs should go to"
}
