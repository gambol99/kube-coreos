#
## Default Security Groups rules
#

# permit all traffic internal within the subnet
resource "aws_security_group_rule" "compute_all_allow" {
  type              = "ingress"
  security_group_id = "${aws_security_group.compute.id}"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  self              = true
}

# permit all traffic internal to the subnet
resource "aws_security_group_rule" "secure_all_allow" {
  type              = "ingress"
  security_group_id = "${aws_security_group.secure.id}"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  self              = true
}

# permit all traffic internal within the subnet
resource "aws_security_group_rule" "public_all_allow" {
  type              = "ingress"
  security_group_id = "${aws_security_group.public.id}"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  self              = true
}

# permit all traffic internal within the subnet
resource "aws_security_group_rule" "mgmt_all_allow" {
  type              = "ingress"
  security_group_id = "${aws_security_group.mgmt.id}"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  self              = true
}

# permit all traffic internal within the subnet
resource "aws_security_group_rule" "elb_all_allow" {
  type              = "ingress"
  security_group_id = "${aws_security_group.elb.id}"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  self              = true
}

#
## Egress Rules
#

# permit all outbound traffic from subnet
resource "aws_security_group_rule" "compute_all_allow_outbound" {
  type              = "egress"
  security_group_id = "${aws_security_group.compute.id}"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  cidr_blocks       = [ "0.0.0.0/0" ]
}

# permit all outbound traffic from subnet
resource "aws_security_group_rule" "secure_all_allow_outbound" {
  type              = "egress"
  security_group_id = "${aws_security_group.secure.id}"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  cidr_blocks       = [ "0.0.0.0/0" ]
}

# permit all outbound traffic from subnet
resource "aws_security_group_rule" "public_all_allow_outbound" {
  type              = "egress"
  security_group_id = "${aws_security_group.public.id}"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  cidr_blocks       = [ "0.0.0.0/0" ]
}

# permit all outbound traffic from subnet
resource "aws_security_group_rule" "elb_all_allow_outbound" {
  type              = "egress"
  security_group_id = "${aws_security_group.elb.id}"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  cidr_blocks       = [ "0.0.0.0/0" ]
}

# permit all outbound traffic from subnet
resource "aws_security_group_rule" "mgmt_all_allow_outbound" {
  type              = "egress"
  security_group_id = "${aws_security_group.mgmt.id}"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  cidr_blocks       = [ "0.0.0.0/0" ]
}

#
## Ingress Rules Compute
#

## Permit SSH from Secure
resource "aws_security_group_rule" "compute_allow_ssh_from_secure" {
  type              = "ingress"
  security_group_id = "${aws_security_group.compute.id}"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  source_security_group_id = "${aws_security_group.secure.id}"
}

## Permit SSH from Management
resource "aws_security_group_rule" "compute_allow_ssh_from_mgmt" {
  type              = "ingress"
  security_group_id = "${aws_security_group.compute.id}"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  source_security_group_id = "${aws_security_group.mgmt.id}"
}

#
## Ingress Rules Secure
#

## Permit SSH from Management
resource "aws_security_group_rule" "secure_allow_ssh_from_mgmt" {
  type              = "ingress"
  security_group_id = "${aws_security_group.secure.id}"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  source_security_group_id = "${aws_security_group.mgmt.id}"
}

#
## Ingress Rules Management
#
resource "aws_security_group_rule" "mgmt_permit_22" {
  type              = "ingress"
  security_group_id = "${aws_security_group.mgmt.id}"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  cidr_blocks       = [ "${var.ssh_access_list}" ]
}
