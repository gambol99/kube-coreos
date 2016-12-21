
## The AWS Provider
provider "aws" {
  profile                 = "${var.aws_profile}"
  region                  = "${var.aws_region}"
  shared_credentials_file = "${var.aws_shared_credentials_file}"
}

## Bastion Image AMI
data "aws_ami" "bastion" {
  most_recent = true
  filter {
    name   = "name"
    values = [ "${var.bastion_image}" ]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["${var.bastion_image_owner}"]
}
