
variable "aws_region" {
  description = "The AWS Region we are building the cluster in"
}
variable "audit_bucket" {
  description = "The name of the s3 bucket the cloudtail logs should go to"
}
