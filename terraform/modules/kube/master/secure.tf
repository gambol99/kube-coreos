#
## Kuberneres Secure Layer Resources
#

## Secure Node Role Policy Template
data "template_file" "secure" {
  template = "${file("${path.module}/assets/iam/secure-role.json")}"

  vars = {
    aws_region          = "${var.aws_region}"
    environment         = "${var.environment}"
    kms_master_id       = "${var.kms_master_id}"
    secrets_bucket_name = "${var.secrets_bucket_name}"
  }
}

## Secure Node instance profile
resource "aws_iam_instance_profile" "secure" {
  name  = "${var.environment}-secure"
  roles = [ "${aws_iam_role.secure.name}" ]
}

## Secure Node UserData template
data "template_file" "secure_user_data" {
  template = "${file("${path.module}/assets/cloudinit/secure.yml")}"

  vars = {
    aws_region             = "${var.aws_region}"
    environment            = "${var.environment}"
    etcd_memberlist        = "${join(",", formatlist("%s=https://%s:2380", keys(var.secure_nodes), values(var.secure_nodes)))}"
    flannel_cidr           = "${var.flannel_cidr}"
    flannel_memberlist     = "${join(",", formatlist("https://%s:2379", values(var.secure_nodes)))}"
    kmsctl_image           = "${var.kmsctl_image}"
    kmsctl_release_md5     = "${var.kmsctl_release_md5}"
    kmsctl_release_url     = "${var.kmsctl_release_url}"
    kubernetes_image       = "${element(split(":", var.kubernetes_image), 0)}"
    kubernetes_version     = "${element(split(":", var.kubernetes_image), 1)}"
    private_zone_name      = "${var.private_zone_name}"
    public_zone_name       = "${var.public_zone_name}"
    secrets_bucket_name    = "${var.secrets_bucket_name}"
    smilodon_release_md5   = "${var.smilodon_release_md5}"
    smilodon_release_url   = "${var.smilodon_release_url}"
  }
}

## Secure Launch Configuration
resource "aws_launch_configuration" "secure" {
  associate_public_ip_address = false
  enable_monitoring           = false
  iam_instance_profile        = "${aws_iam_instance_profile.secure.name}"
  image_id                    = "${data.aws_ami.coreos.id}"
  instance_type               = "${var.secure_flavor}"
  key_name                    = "${var.key_name}"
  name_prefix                 = "${var.environment}-secure-"
  security_groups             = [ "${var.secure_sg}" ]
  user_data                   = "${data.template_file.secure_user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    delete_on_termination = true
    volume_size           = "${var.secure_root_volume}"
    volume_type           = "gp2"
  }

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/xvdd"
    volume_size           = "${var.secure_docker_volume}"
    volume_type           = "gp2"
  }
}

## Secure AutoScaling Group
resource "aws_autoscaling_group" "secure" {
  default_cooldown          = "${var.secure_asg_grace_period}"
  desired_capacity          = "${length(values(var.secure_nodes))}"
  force_delete              = true
  health_check_grace_period = 10
  health_check_type         = "EC2"
  launch_configuration      = "${aws_launch_configuration.secure.name}"
  max_size                  = "${length(values(var.secure_nodes))+2}"
  min_size                  = "${length(values(var.secure_nodes))}"
  name                      = "${var.environment}-secure-asg"
  termination_policies      = [ "OldestInstance", "Default" ]
  vpc_zone_identifier       = [ "${var.secure_subnets}" ]

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

### Secure Etcd ELB
#resource "aws_elb" "etcd" {
#  internal        = true
#  depends_on      = [ "aws_security_group.secure_elb" ]
#  name            = "${var.environment}-secure-elb"
#  subnets         = [ "${var.secure_subnets}" ]
#  security_groups = [ "${aws_security_group.secure_elb.id}" ]
#
#  listener {
#    instance_port       = 2379
#    instance_protocol   = "tcp"
#    lb_port             = 2379
#    lb_protocol         = "tcp"
#  }
#
#  health_check {
#    healthy_threshold   = 2
#    unhealthy_threshold = 3
#    timeout             = 10
#    target              = "TCP:2379"
#    interval            = 15
#  }
#
#  connection_draining         = true
#  connection_draining_timeout = 120
#  cross_zone_load_balancing   = true
#  idle_timeout                = 30
#
#  tags {
#    Name = "${var.environment}-etcd-elb"
#    Env  = "${var.environment}"
#    Role = "etcd-elb"
#  }
#}
#
### Attach the Secure ELB to Secure ASG
#resource "aws_autoscaling_attachment" "kubeapi_internal" {
#  autoscaling_group_name = "${aws_autoscaling_group.secure.name}"
#  elb                    = "${aws_elb.etcd.id}"
#}
#
### DNS Name for Secure API ELB
#resource "aws_route53_record" "etcd" {
#  zone_id = "${var.private_zone}"
#  name    = "${var.etcd_dns}.${var.private_zone_name}"
#  type    = "A"
#
#  alias {
#    name                   = "${aws_elb.etcd.dns_name}"
#    zone_id                = "${aws_elb.etcd.zone_id}"
#    evaluate_target_health = true
#  }
#}
#
