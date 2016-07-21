
#
## Secure Node Role Policy Template
#
resource "template_file" "secure" {
  template = "${file(\"kubernetes/assets/iam/secure-role.json\")}"

  vars = {
    aws_account         = "${var.aws_account}"
    aws_region          = "${var.aws_region}"
    environment         = "${var.environment}"
    kms_master_id       = "${var.kms_master_id}"
    secrets_bucket_name = "${var.secrets_bucket_name}"
  }
}

## Secure Node Role Policy
#
resource "aws_iam_role_policy" "secure" {
  name   = "${var.environment}-secure-role"
  role   = "${aws_iam_role.secure.id}"
  policy = "${template_file.secure.rendered}"
}

#
## Secure Node instance profile
#
resource "aws_iam_instance_profile" "secure" {
  name  = "${var.environment}-secure"
  roles = [ "${aws_iam_role.secure.name}" ]
}

#
## Secure Node UserData template
#
resource "template_file" "secure_user_data" {
  template = "${file(\"kubernetes/assets/cloudinit/secure.yml\")}"

  lifecycle {
    create_before_destroy = true
  }

  vars = {
    aws_region             = "${var.aws_region}"
    dns_zone_name          = "${var.dns_zone_name}"
    environment            = "${var.environment}"
    etcd_discovery_md5     = "${var.etcd_discovery_md5}"
    etcd_discovery_url     = "${var.etcd_discovery_url}"
    kubernetes_image       = "${var.kubernetes_image}"
    kubernetes_version     = "${var.kubernetes_version}"
    platform               = "${var.platform}"
    kmsctl_release_md5     = "${var.kmsctl_release_md5}"
    kmsctl_release_url     = "${var.kmsctl_release_url}"
    secrets_bucket_name    = "${var.secrets_bucket_name}"
  }
}

#
## Secure Launch Configuration
#
resource "aws_launch_configuration" "secure" {
  associate_public_ip_address = true
  enable_monitoring           = false
  iam_instance_profile        = "${aws_iam_instance_profile.secure.name}"
  image_id                    = "${var.coreos_image}"
  instance_type               = "${var.secure_flavor}"
  key_name                    = "${aws_key_pair.default.id}"
  name_prefix                 = "${var.environment}-secure"
  security_groups             = [ "${aws_security_group.secure.id}" ]
  user_data                   = "${template_file.secure_user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    delete_on_termination = true
    volume_size           = "${var.secure_root_volume_size}"
    volume_type           = "gp2"
  }
}

#
## Secure AutoScaling Group
#
resource "aws_autoscaling_group" "secure" {
  default_cooldown          = "${var.secure_asg_grace_period}"
  desired_capacity          = "${var.secure_asg_min}"
  force_delete              = true
  health_check_grace_period = 10
  health_check_type         = "EC2"
  launch_configuration      = "${aws_launch_configuration.secure.name}"
  load_balancers            = [ "${aws_elb.secure.name}", "${aws_elb.kube.name}", "${aws_elb.kubeapi.name}" ]
  max_size                  = "${var.secure_asg_max}"
  min_size                  = "${var.secure_asg_min}"
  name                      = "${var.environment}-secure-asg"
  termination_policies      = [ "OldestInstance", "Default" ]
  vpc_zone_identifier       = [ "${aws_subnet.secure_subnets.*.id}" ]

  tag {
    key                 = "Name"
    value               = "${var.environment}-secure"
    propagate_at_launch = true
  }

  tag {
    key                 = "Env"
    value               = "${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = "secure"
    propagate_at_launch = true
  }
}

#
## Secure Etcd ELB
#
resource "aws_elb" "secure" {
  internal        = true
  depends_on      = [ "aws_security_group.secure_elb" ]
  name            = "${var.environment}-secure-elb"
  subnets         = [ "${aws_subnet.secure_subnets.*.id}" ]
  security_groups = [ "${aws_security_group.secure_elb.id}" ]

  listener {
    instance_port       = 2379
    instance_protocol   = "tcp"
    lb_port             = 2379
    lb_protocol         = "tcp"
  }

  listener {
    instance_port       = 4001
    instance_protocol   = "tcp"
    lb_port             = 4001
    lb_protocol         = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 10
    target              = "TCP:2379"
    interval            = 15
  }

  connection_draining         = true
  connection_draining_timeout = 120
  cross_zone_load_balancing   = true
  idle_timeout                = 30

  tags {
    Name = "${var.environment}-secure-elb"
    Env  = "${var.environment}"
    Role = "secure-elb"
  }
}

#
## Kube API for KubeAPI ELB
#
resource "aws_elb" "kube" {
  internal        = true
  name            = "${var.environment}-kube-elb"
  subnets         = [ "${aws_subnet.secure_subnets.*.id}" ]
  security_groups = [ "${aws_security_group.kube_elb.id}" ]

  listener {
    instance_port       = 6443
    instance_protocol   = "tcp"
    lb_port             = 443
    lb_protocol         = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 10
    target              = "TCP:6443"
    interval            = 15
  }

  connection_draining         = true
  connection_draining_timeout = 120
  cross_zone_load_balancing   = true
  idle_timeout                = 30

  tags {
    Name = "${var.environment}-kube"
    Env  = "${var.environment}"
    Role = "kube"
  }
}

#
## Ingres Rule permits compute subnets access to Kubernetes API
#
resource "aws_security_group_rule" "secure_elb_permit_compute_2379" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.secure_elb.id}"
  from_port                = 2379
  to_port                  = 2379
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.compute.id}"
}

#
## Egress Rule permits outbound secure from elb
#
resource "aws_security_group_rule" "secure_elb_permit_2379" {
  type                     = "egress"
  security_group_id        = "${aws_security_group.secure_elb.id}"
  protocol                 = "tcp"
  from_port                = 2379
  to_port                  = 2379
  source_security_group_id = "${aws_security_group.secure.id}"
}

#
## Ingres Rule permits traffic from seccure -> elb
#
resource "aws_security_group_rule" "secure_elb_permitted" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.secure.id}"
  protocol                 = "tcp"
  from_port                = 2379
  to_port                  = 2379
  source_security_group_id = "${aws_security_group.secure_elb.id}"
}

#
## Ingres Rule permits compute subnets access to Kubernetes API
#
resource "aws_security_group_rule" "kube_elb_allow_compute_443" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.kube_elb.id}"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  source_security_group_id = "${aws_security_group.compute.id}"
}

#
## Ingres Rule permits outbound Kubernetes API
#
resource "aws_security_group_rule" "kube_elb_allow_compute_6443" {
  type                     = "egress"
  security_group_id        = "${aws_security_group.kube_elb.id}"
  protocol                 = "tcp"
  from_port                = 6443
  to_port                  = 6443
  source_security_group_id = "${aws_security_group.secure.id}"
}

#
## Ingress ELB Rule for Kubernetes API
#
resource "aws_security_group_rule" "kube_elb_allow_443" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.secure.id}"
  protocol                 = "tcp"
  from_port                = 6443
  to_port                  = 6443
  source_security_group_id = "${aws_security_group.kube_elb.id}"
}

#
## DNS Name for Kube API ELB
#
resource "aws_route53_record" "kube" {
  zone_id = "${aws_route53_zone.default.zone_id}"
  name    = "kube.${var.dns_zone_name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.kube.dns_name}"
    zone_id                = "${aws_elb.kube.zone_id}"
    evaluate_target_health = true
  }
}

#
## DNS Name for Secure API ELB
#
resource "aws_route53_record" "secure" {
  zone_id = "${aws_route53_zone.default.zone_id}"
  name    = "secure.${var.dns_zone_name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.secure.dns_name}"
    zone_id                = "${aws_elb.secure.zone_id}"
    evaluate_target_health = true
  }
}
