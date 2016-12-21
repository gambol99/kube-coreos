

## Kube ELB Security Group
resource "aws_security_group" "kubeapi" {
  name        = "${var.environment}-kubeapi-elb"
  description = "Kubernetes External API ELB Security Group for ${var.environment} environment"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name = "${var.environment}-kubeapi-elb"
    Env  = "${var.environment}"
    Role = "kubeapi-elb"
  }
}

## Kube Internal ELB Security Group
resource "aws_security_group" "kubeapi_internal" {
  name        = "${var.environment}-kubeapi-internal-elb"
  description = "Kubernetes Internal API ELB Security Group for ${var.environment} environment"
  vpc_id      = "${var.vpc_id}"

  tags {
    Name = "${var.environment}-kubeapi-internal-elb"
    Env  = "${var.environment}"
    Role = "kubeapi-elb"
  }
}

##
### KubeAPI Rules
##

## Ingress Rule permits external access to Kubernetes API
resource "aws_security_group_rule" "kubeapi_permit_443" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.kubeapi.id}"
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  cidr_blocks              = [ "${var.kubeapi_access_list}" ]
}

## Ingress Rule permits Kubernetes API ELB -> Secure
resource "aws_security_group_rule" "kubeapi_permit_6443" {
  type                     = "ingress"
  security_group_id        = "${var.secure_sg}"
  protocol                 = "tcp"
  from_port                = 6443
  to_port                  = 6443
  source_security_group_id = "${aws_security_group.kubeapi.id}"
}
## Engress Rules permits ELB -> Secure
resource "aws_security_group_rule" "kubeapi_permit_outbound_6443" {
  type                     = "egress"
  security_group_id        = "${aws_security_group.kubeapi.id}"
  protocol                 = "tcp"
  from_port                = 6443
  to_port                  = 6443
  source_security_group_id = "${var.secure_sg}"
}

##
### KubeAPI Internal Rules
##

## Ingress: Permit compute boxes to API
resource "aws_security_group_rule" "kubeapi_internal_permit_443_compute" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.kubeapi_internal.id}"
  protocol                 = "tcp"
  from_port                = "443"
  to_port                  = "443"
  source_security_group_id = "${var.compute_sg}"
}

## Ingress: Permit secure boxes to API
resource "aws_security_group_rule" "kubeapi_internal_permit_443_secure" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.kubeapi_internal.id}"
  protocol                 = "tcp"
  from_port                = "443"
  to_port                  = "443"
  source_security_group_id = "${var.secure_sg}"
}

## Ingress: Permit all inbound from ELB -> Secure
resource "aws_security_group_rule" "kubeapi_internal_permit_6443" {
  type                     = "ingress"
  security_group_id        = "${var.secure_sg}"
  protocol                 = "tcp"
  from_port                = "6443"
  to_port                  = "6443"
  source_security_group_id = "${aws_security_group.kubeapi_internal.id}"
}

## Engress Rules permits ELB -> Secure
resource "aws_security_group_rule" "kubeapi_internal_outbound_6443" {
  type                     = "egress"
  security_group_id        = "${aws_security_group.kubeapi_internal.id}"
  protocol                 = "tcp"
  from_port                = 6443
  to_port                  = 6443
  source_security_group_id = "${var.secure_sg}"
}
