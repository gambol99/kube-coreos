
#
## The AWS Provider
#
provider "aws" {
  max_retries             = "10"
  profile                 = "${var.aws_profile}"
  region                  = "${var.aws_region}"
  shared_credentials_file = "${var.aws_shared_credentials_file}"
}

#
## Default Environment Keypair
#
resource "aws_key_pair" "default" {
  key_name = "${var.environment}-key"
  public_key = "${file("../secrets/locked/${var.environment}.pub")}"
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
