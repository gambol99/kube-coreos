
## Userdata Template
data "template_file" "user_data" {
  template = "${file("${path.module}/assets/cloudinit/bastion.yml")}"

  vars {
    secrets_bucket_name   = "${var.s3_bucket_name}"
    kubernetes_image      = "${var.kubernetes_image}"
    kmsctl_image          = "${var.kmsctl_image}"
    kubernetes_version    = "${var.kubernetes_version}"
  }
}

## Bastion Launch Configuration
resource "aws_launch_configuration" "bastion" {
  associate_public_ip_address = true
  iam_instance_profile        = "${var.iam_instance_profile}"
  image_id             = "${var.ami}"
  instance_type        = "${var.bastion_flavor}"
  key_name             = "${var.key_name}"
  name_prefix          = "bastion-"
  security_groups      = [ ${var.mgmt_sg ]
  user_data            = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

## Bastion ASG
resource "aws_autoscaling_group" "bastion" {
  name                      = "${var.environment}-bastion"
  vpc_zone_identifier       = [ "${var.mgmt_subnets}" ]
  desired_capacity          = "1"
  min_size                  = "1"
  max_size                  = "1"
  health_check_grace_period = "60"
  health_check_type         = "EC2"
  force_delete              = false
  wait_for_capacity_timeout = 0
  launch_configuration      = "${aws_launch_configuration.bastion.name}"
  enabled_metrics           = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

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
