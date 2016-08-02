
#
## KubeAPI ELB
#
resource "aws_elb" "kubeapi" {
  name            = "${var.environment}-kubeapi"
  subnets         = [ "${aws_subnet.secure_subnets.*.id}" ]
  security_groups = [ "${aws_security_group.kubeapi_elb.id}" ]

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
    Name = "${var.environment}-kubeapi-elb"
    Env  = "${var.environment}"
    Role = "kube"
  }
}

#
## Ingres Rule permits external access to Kubernetes API
#
resource "aws_security_group_rule" "kubeapi_allow_443" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.kubeapi_elb.id}"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  cidr_blocks              = [ "${split(",", var.kubeapi_access_list)}" ]
}

#
## Egress Rule for Kubernetes API
#
resource "aws_security_group_rule" "kubeapi_elb_allow_443" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.secure.id}"
  protocol                 = "tcp"
  from_port                = 6443
  to_port                  = 6443
  source_security_group_id = "${aws_security_group.kubeapi_elb.id}"
}
