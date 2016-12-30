
## The AWS Provider
provider "aws" {
  profile                 = "${var.aws_profile}"
  region                  = "${var.aws_region}"
  shared_credentials_file = "${var.aws_shared_credentials_file}"
}

## CoreOS Image AMI
data "aws_ami" "coreos" {
  most_recent = true
  filter {
    name   = "name"
    values = [ "${var.coreos_image}" ]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["${var.coreos_image_owner}"]
}

## AWS Account
data "aws_caller_identity" "caller" { }
