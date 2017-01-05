
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

## Instance profile
resource "aws_iam_instance_profile" "bastion" {
  name  = "${var.environment}-bastion"
  roles = [ "${aws_iam_role.bastion.name}" ]
}

## Userdata Template
data "template_file" "user_data" {
  template = "${file("${path.module}/assets/cloudinit/bastion.yml")}"

  vars {
    aws_region          = "${var.aws_region}"
    environment         = "${var.environment}"
    kmsctl_image        = "${var.kmsctl_image}"
    kubernetes_image    = "${element(split(":", var.kubernetes_image), 0)}"
    kubernetes_version  = "${element(split(":", var.kubernetes_image), 1)}"
    private_zone_name   = "${var.private_zone_name}"
    public_zone_name    = "${var.public_zone_name}"
    secrets_bucket_name = "${var.secrets_bucket_name}"
  }
}

## Bastion Launch Configuration
resource "aws_launch_configuration" "bastion" {
  associate_public_ip_address = true
  enable_monitoring           = false
  iam_instance_profile        = "${aws_iam_instance_profile.bastion.name}"
  image_id                    = "${data.aws_ami.bastion.id}"
  instance_type               = "${var.bastion_flavor}"
  key_name                    = "${var.key_name}"
  name_prefix                 = "${var.environment}-bastion-"
  security_groups             = [ "${var.bastion_sg}" ]
  user_data                   = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    delete_on_termination = true
    volume_size           = 24
    volume_type           = "gp2"
  }

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/xvdd"
    volume_size           = 24
    volume_type           = "gp2"
  }
}

## Bastion ASG
resource "aws_autoscaling_group" "bastion" {
  desired_capacity          = "${var.bastion_count}"
  force_delete              = true
  health_check_grace_period = "10"
  health_check_type         = "EC2"
  launch_configuration      = "${aws_launch_configuration.bastion.name}"
  max_size                  = "${var.bastion_count}"
  min_size                  = "${var.bastion_count}"
  name                      = "${var.environment}-bastion"
  termination_policies      = [ "OldestInstance", "Default" ]
  vpc_zone_identifier       = [ "${var.bastion_subnets}" ]
  wait_for_capacity_timeout = "1m"

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-bastion"
    propagate_at_launch = true
  }

  tag {
    key                 = "Env"
    value               = "${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = "bastion"
    propagate_at_launch = true
  }
}
