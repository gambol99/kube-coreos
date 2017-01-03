
## Secrets Bucket
resource "aws_s3_bucket" "secrets" {
  acl           = "private"
  bucket        = "${var.secrets_bucket_name}"
  force_destroy = true

  versioning {
    enabled = true
  }

  tags {
    Name        = "${var.secrets_bucket_name}"
    Environment = "${var.environment}"
    Role        = "secrets"
  }
}

## Default Environment Keypair
resource "aws_key_pair" "default" {
  key_name = "${var.environment}-key"
  public_key = "${file("../secrets/locked/${var.environment}.pub")}"
}
