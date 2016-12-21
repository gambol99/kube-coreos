
## Kube API for KubeAPI ELB - is the API used by the compute nodes internally
resource "aws_elb" "kubeapi_internal" {
  internal        = true
  name            = "${var.environment}-kube-internal-elb"
  subnets         = [ "${var.secure_subnets}" ]
  security_groups = [ "${aws_security_group.kubeapi_internal.id}" ]

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
    Name = "${var.environment}-kubeapi-internal"
    Env  = "${var.environment}"
    Role = "kubeapi"
  }
}

## KubeAPI ELB - the external kubernetes API using by clients
resource "aws_elb" "kubeapi" {
  count           = "${var.kubeapi_external_elb}"
  name            = "${var.environment}-kubeapi"
  subnets         = [ "${var.elb_subnets}" ]
  security_groups = [ "${aws_security_group.kubeapi.id}" ]

  listener {
    instance_port       = 6443
    instance_protocol   = "tcp"
    lb_port             = 443
    lb_protocol         = "tcp"
  }

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 3
    timeout             = 5
    target              = "TCP:6443"
    interval            = 10
  }

  connection_draining         = true
  connection_draining_timeout = 120
  cross_zone_load_balancing   = true
  idle_timeout                = 120

  tags {
    Name = "${var.environment}-kubeapi"
    Env  = "${var.environment}"
    Role = "kubeapi"
  }
}

## Attach the KubeAPI Internal to Secure ASG
resource "aws_autoscaling_attachment" "kubeapi_internal" {
  autoscaling_group_name = "${var.secure_asg}"
  elb                    = "${aws_elb.kubeapi_internal.id}"
}

## Attach the KubeAPI to Secure ASG
resource "aws_autoscaling_attachment" "kubeapi" {
  autoscaling_group_name = "${var.secure_asg}"
  elb                    = "${aws_elb.kubeapi.id}"
}
