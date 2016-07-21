
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
## Default Environment Keypair
#
resource "aws_key_pair" "default" {
  key_name = "${var.environment}-key"
  public_key = "${file(\"../secrets/locked/${var.environment}.pub\")}"
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
