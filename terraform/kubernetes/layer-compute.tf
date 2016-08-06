#
## Compute Node IAM Policy Template
#
data "template_file" "compute_policy" {
  template = "${file("kubernetes/assets/iam/compute-role.json")}"
  vars = {
    aws_account         = "${var.aws_account}"
    aws_region          = "${var.aws_region}"
    environment         = "${var.environment}"
    kms_master_id       = "${var.kms_master_id}"
    secrets_bucket_name = "${var.secrets_bucket_name}"
  }
}

#
## Compute Note Role Policy
#
resource "aws_iam_role_policy" "compute_policy" {
  name   = "${var.environment}-compute-role"
  role   = "${aws_iam_role.compute.id}"
  policy = "${data.template_file.compute_policy.rendered}"
}

#
## Compute Node Instance Profile
#
resource "aws_iam_instance_profile" "compute" {
  name  = "${var.environment}-compute"
  roles = [ "${aws_iam_role.compute.name}" ]
}

#
## Compute UserData Template
#
data "template_file" "compute_user_data" {
  template = "${file("kubernetes/assets/cloudinit/compute.yml")}"

  vars = {
    aws_region                     = "${var.aws_region}"
    dns_zone_name                  = "${var.dns_zone_name}"
    environment                    = "${var.environment}"
    etcd_discovery_md5             = "${var.etcd_discovery_md5}"
    etcd_discovery_url             = "${var.etcd_discovery_url}"
    flannel_cidr                   = "${var.flannel_cidr}"
    kmsctl_release_md5             = "${var.kmsctl_release_md5}"
    kmsctl_release_url             = "${var.kmsctl_release_url}"
    kube_elb_dns_name              = "kube.${var.dns_zone_name}"
    kubernetes_dns_service_address = "${var.kubernetes_dns_service_address}"
    kubernetes_image               = "${var.kubernetes_image}"
    kubernetes_version             = "${var.kubernetes_version}"
    platform                       = "${var.platform}"
    secrets_bucket_name            = "${var.secrets_bucket_name}"
    secure_asg_name                = "${var.environment}-secure-asg"
  }
}

#
## Compute Launch Configuration
#
resource "aws_launch_configuration" "compute" {
  associate_public_ip_address = true
  enable_monitoring           = false
  iam_instance_profile        = "${aws_iam_instance_profile.compute.name}"
  image_id                    = "${var.coreos_image}"
  instance_type               = "${var.compute_flavor}"
  key_name                    = "${aws_key_pair.default.id}"
  name_prefix                 = "${var.environment}-compute_"
  security_groups             = [ "${aws_security_group.compute.id}" ]
  user_data                   = "${data.template_file.compute_user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    delete_on_termination = true
    volume_size           = "${var.compute_root_volume_size}"
    volume_type           = "gp2"
  }

  ebs_block_device {
    device_name           = "/dev/xvdd"
    delete_on_termination = true
    volume_type           = "${var.compute_docker_volume_type}"
    volume_size           = "${var.compute_docker_volume_size}"
  }
}

resource "aws_autoscaling_group" "compute" {
  default_cooldown          = "${var.compute_asg_grace_period}"
  force_delete              = true
  health_check_grace_period = 10
  health_check_type         = "EC2"
  launch_configuration      = "${aws_launch_configuration.compute.name}"
  max_size                  = "${var.compute_asg_max}"
  min_size                  = "${var.compute_asg_min}"
  name                      = "${var.environment}-compute-asg"
  termination_policies      = [ "OldestInstance", "Default" ]
  vpc_zone_identifier       = [ "${aws_subnet.compute_subnets.*.id}" ]

  tag {
    key                 = "Name"
    value               = "${var.environment}-compute"
    propagate_at_launch = true
  }

  tag {
    key                 = "Env"
    value               = "${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = "compute"
    propagate_at_launch = true
  }

  tag {
    key                 = "KubernetesCluster"
    value               = "${var.environment}"
    propagate_at_launch = true
  }
}
