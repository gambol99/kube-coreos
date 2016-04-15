
#
## The AWS Provider
#
provider "aws" {
  access_key  = "${var.aws_access_key}"
  secret_key  = "${var.aws_secret_key}"
  region      = "${var.aws_region}"
  max_retries = "5"
}

#
## Terraform remote state
#
#resource "terraform_remote_state" "state" {
#  backend = "s3"
#  config {
#    access_key  = "${var.aws_access_key}"
#    bucket      = "${var.terraform_bucket_name}"
#    key         = "${var.aws_region}/${var.environment}/${var.platform}/terraform.tfstate"
#    region      = "${var.aws_region}"
#    secret_key  = "${var.aws_secret_key}"
#    encrypt     = true
#  }
#}

#
## Default Environment Keypair
#
resource "aws_key_pair" "default" {
  key_name = "${var.environment}-key"
  public_key = "${file(\"../secrets/${var.environment}.pub\")}"
}

#
## Route53 Domain
#
resource "aws_route53_zone" "default" {
  name            = "${var.dns_zone_name}"
  comment         = "DSP Domain"

  tags {
    Name        = "${var.dns_zone_name}"
    Environment = "${var.environment}"
    Role        = "dns"
  }
}

#
## S3 bucket used to hold secrets
#
resource "aws_s3_bucket" "secrets" {
  acl           = "private"
  bucket        = "${var.secrets_bucket_name}"
  force_destroy = true

  tags {
    Name        = "${var.secrets_bucket_name}"
    Environment = "${var.environment}"
  }
}
