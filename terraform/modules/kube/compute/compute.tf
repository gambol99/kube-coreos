#
## Kuberneres Compute Layer Resources
#

## Instance Profile
resource "aws_iam_instance_profile" "compute" {
  name  = "${var.environment}-compute"
  roles = [ "${aws_iam_role.compute.name}" ]
}

## UserData Template
data "gotemplate_file" "compute_user_data" {
  template = "${file("${path.module}/assets/cloudinit/compute.yml")}"

  vars = {
    aws_region             = "${var.aws_region}"
    enable_calico          = "${var.enable_calico}"
    environment            = "${var.environment}"
    flannel_memberlist     = "${var.flannel_memberlist}"
    kmsctl_image           = "${var.kmsctl_image}"
    kmsctl_release_md5     = "${var.kmsctl_release_md5}"
    kmsctl_release_url     = "${var.kmsctl_release_url}"
    kubeapi_dns            = "${var.kubeapi_dns}"
    kubernetes_image       = "${element(split(":", var.kubernetes_image), 0)}"
    kubernetes_version     = "${element(split(":", var.kubernetes_image), 1)}"
    private_zone_name      = "${var.private_zone_name}"
    public_zone_name       = "${var.public_zone_name}"
    secrets_bucket_name    = "${var.secrets_bucket_name}"
  }
}

## Launch Configuration
resource "aws_launch_configuration" "compute" {
  associate_public_ip_address = false
  enable_monitoring           = false
  iam_instance_profile        = "${aws_iam_instance_profile.compute.name}"
  image_id                    = "${data.aws_ami.coreos.id}"
  instance_type               = "${var.compute_flavor}"
  key_name                    = "${var.key_name}"
  name_prefix                 = "${var.environment}-compute-"
  security_groups             = [ "${var.compute_sg}" ]
  user_data                   = "${data.gotemplate_file.compute_user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    delete_on_termination = true
    volume_size           = "${var.compute_root_volume}"
    volume_type           = "gp2"
  }

  ebs_block_device {
    device_name           = "/dev/xvdd"
    delete_on_termination = true
    volume_type           = "${var.compute_docker_volume_type}"
    volume_size           = "${var.compute_docker_volume}"
  }
}

# AutoScaling Group
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
  vpc_zone_identifier       = [ "${var.compute_subnets}" ]

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
