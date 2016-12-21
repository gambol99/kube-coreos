
## Secure ELB Security Group
resource "aws_security_group" "secure_elb" {
  name        = "${var.environment}-secure-elb"
  description = "Secure ELB Security Group for ${var.environment} environment"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name = "${var.environment}-secure-elb"
    Env  = "${var.environment}"
    Role = "secure-elb"
  }
}

#
## Ingress Secure
#

## Permit Etcd client from compute boxes
resource "aws_security_group_rule" "secure_permit_etcd_client" {
  type                     = "ingress"
  security_group_id        = "${var.secure_sg}"
  protocol                 = "tcp"
  from_port                = "2379"
  to_port                  = "2379"
  source_security_group_id = "${var.compute_sg}"
}

## Permit flannel vxlan udp from compute
resource "aws_security_group_rule" "secure_permit_vxlan" {
  type                     = "ingress"
  security_group_id        = "${var.secure_sg}"
  protocol                 = "udp"
  from_port                = "8472"
  to_port                  = "8472"
  source_security_group_id = "${var.compute_sg}"
}

## Permit kube api from compute
resource "aws_security_group_rule" "secure_permit_6443" {
  type                     = "ingress"
  security_group_id        = "${var.secure_sg}"
  protocol                 = "tcp"
  from_port                = "6443"
  to_port                  = "6443"
  source_security_group_id = "${var.compute_sg}"
}

#
## Secure ELB Rules
#

## Ingress: Rule permits compute subnets access to Kubernetes API
resource "aws_security_group_rule" "secure_elb_permit_2379_compute" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.secure_elb.id}"
  from_port                = 2379
  to_port                  = 2379
  protocol                 = "tcp"
  source_security_group_id = "${var.compute_sg}"
}

## Ingress: Rule permits traffic from secure -> elb
resource "aws_security_group_rule" "secure_elb_permit_2379_secure" {
  type                     = "ingress"
  security_group_id        = "${var.secure_sg}"
  protocol                 = "tcp"
  from_port                = 2379
  to_port                  = 2379
  source_security_group_id = "${aws_security_group.secure_elb.id}"
}

## Egress: Rule permits traffic from secure -> elb
resource "aws_security_group_rule" "secure_elb_outbound_2379" {
  type                     = "egress"
  security_group_id        = "${aws_security_group.secure_elb.id}"
  protocol                 = "tcp"
  from_port                = 2379
  to_port                  = 2379
  source_security_group_id = "${var.secure_sg}"
}
