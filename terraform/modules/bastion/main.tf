
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
