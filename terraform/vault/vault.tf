#
## Vault Node Role Policy Template
#
resource "template_file" "vault" {
  template = "${file(\"vault/assets/iam/vault-role.json\")}"
  vars = {
    aws_region          = "${var.aws_region}"
    environment         = "${var.environment}"
    kms_master_id       = "${var.kms_master_id}"
    secrets_bucket_name = "${var.secrets_bucket_name}"
  }
}

#
## Vault Node Role Policy
#
resource "aws_iam_role_policy" "vault" {
  name   = "${var.environment}-vault-role"
  role   = "${aws_iam_role.vault.id}"
  policy = "${template_file.vault.rendered}"
}

#
## Vailt Node instance profile
#
resource "aws_iam_instance_profile" "vault" {
  name  = "${var.environment}-vault"
  roles = [ "${aws_iam_role.vault.name}" ]
}

#
## Vault Node UserData template
#
resource "template_file" "vault_user_data" {
  template   = "${file(\"vault/assets/cloudinit/vault.yml\")}"

  lifecycle {
    create_before_destroy = true
  }

  vars = {
    aws_region               = "${var.aws_region}"
    dns_zone_name            = "${var.dns_zone_name}"
    environment              = "${var.environment}"
    etcd_discovery_md5       = "${var.etcd_discovery_md5}"
    etcd_discovery_url       = "${var.etcd_discovery_url}"
    vault_release_url        = "https://dl.bintray.com/mitchellh/vault/vault_${var.vault_release_version}_linux_amd64.zip"
    vault_release_md5        = "${var.vault_release_md5}"
    s3secrets_release_md5    = "${var.s3secrets_release_md5}"
    s3secrets_release_url    = "${var.s3secrets_release_url}"
    secrets_bucket_name      = "${var.secrets_bucket_name}"
  }
}

#
## Vault Node Autoscaling Policy
#
resource "aws_autoscaling_policy" "vault" {
  name                   = "${var.environment}-vault-asg"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "${var.vault_asg_grace_period}"
  autoscaling_group_name = "${aws_autoscaling_group.vault.name}"
}

#
## Launch configuration for Vault
#
resource "aws_launch_configuration" "vault" {
  associate_public_ip_address = true
  enable_monitoring           = false
  iam_instance_profile        = "${aws_iam_instance_profile.vault.name}"
  image_id                    = "${var.coreos_image}"
  instance_type               = "${var.secure_flavor}"
  key_name                    = "${aws_key_pair.default.id}"
  name_prefix                 = "${var.environment}-vault_"
  security_groups             = [ "${aws_security_group.vault_sg.id}" ]
  user_data                   = "${template_file.vault_user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    delete_on_termination = true
    volume_size           = "${var.vault_root_volume_size}"
    volume_type           = "gp2"
  }
}

#
## Vault AutoScaling Group
#
resource "aws_autoscaling_group" "vault" {
  default_cooldown          = "${var.vault_asg_grace_period}"
  desired_capacity          = "${var.vault_asg_min}"
  force_delete              = true
  health_check_grace_period = 10
  health_check_type         = "EC2"
  launch_configuration      = "${aws_launch_configuration.vault.name}"
  load_balancers            = [ "${aws_elb.vault.name}" ]
  max_size                  = "${var.vault_asg_max}"
  min_size                  = "${var.vault_asg_min}"
  name                      = "${var.environment}-vault-asg"
  termination_policies      = [ "OldestInstance", "Default" ]
  vpc_zone_identifier       = [ "${aws_subnet.vault_subnets.*.id}" ]

  tag {
    key                 = "Name"
    value               = "${var.environment}-vault"
    propagate_at_launch = true
  }

  tag {
    key                 = "Env"
    value               = "${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = "vault"
    propagate_at_launch = true
  }
}

#
## Vault ELB Security Group
#
resource "aws_security_group" "vault_elb_sg" {
  depends_on  = [ "aws_security_group.vault_sg" ]
  name        = "${var.environment}-vault-elb-sg"
  description = "Vault ELB Security Group (${var.environment})"
  vpc_id      = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.environment}-vault-elb-sg"
    Env  = "${var.environment}"
  }

  ingress {
    from_port       = 8200
    to_port         = 8200
    protocol        = "tcp"
    cidr_block      = "10.99.0.0/16"
  }

  egress {
    from_port       = 8200
    to_port         = 8200
    protocol        = "tcp"
    cidr_block      = "10.99.0.0/16"
  }
}

#
## Vault Etcd ELB
#
resource "aws_elb" "vault" {
  internal        = true
  depends_on      = [ "aws_security_group.vault_elb_sg" ]
  name            = "${var.environment}-vault-elb"
  subnets         = [ "${aws_subnet.vault_subnets.*.id}" ]
  security_groups = [ "${aws_security_group.vault_elb_sg.id}" ]

  listener {
    instance_port       = 8200
    instance_protocol   = "tcp"
    lb_port             = 8200
    lb_protocol         = "tcp"
  }

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 3
    timeout             = 5
    target              = "TCP:8200"
    interval            = 10
  }

  connection_draining         = true
  connection_draining_timeout = 120
  cross_zone_load_balancing   = true
  idle_timeout                = 30

  tags {
    Name = "${var.environment}-vault-elb"
    Env  = "${var.environment}"
    Role = "vault-elb"
  }
}

#
## DNS Name for secure ELB
#
resource "aws_route53_record" "vault" {
  zone_id = "${aws_route53_zone.default.zone_id}"
  name    = "vault.${var.dns_zone_name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.vault.dns_name}"
    zone_id                = "${aws_elb.vault.zone_id}"
    evaluate_target_health = true
  }
}
