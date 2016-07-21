
# permit all traffic internal to the subnet
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

# permit all traffic internal to the subnet
resource "aws_security_group_rule" "public_all_allow" {
  type              = "ingress"
  security_group_id = "${aws_security_group.public.id}"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  self              = true
}

# permit all compute outbound
resource "aws_security_group_rule" "compute_all_allow_outbound" {
  type              = "egress"
  security_group_id = "${aws_security_group.compute.id}"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  cidr_blocks       = [ "0.0.0.0/0" ]
}

resource "aws_security_group_rule" "secure_all_allow_outbound" {
  type              = "egress"
  security_group_id = "${aws_security_group.secure.id}"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  cidr_blocks       = [ "0.0.0.0/0" ]
}

resource "aws_security_group_rule" "public_all_allow_outbound" {
  type              = "egress"
  security_group_id = "${aws_security_group.public.id}"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  cidr_blocks       = [ "0.0.0.0/0" ]
}

# permitt ssh from the access list
resource "aws_security_group_rule" "compute_22_allow" {
  type              = "ingress"
  security_group_id = "${aws_security_group.compute.id}"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  cidr_blocks       = [ "${aws_subnet.secure_subnets.*.cidr_block}" ]
}

# permitt ssh from the access list
resource "aws_security_group_rule" "secure_permit_22" {
  type              = "ingress"
  security_group_id = "${aws_security_group.secure.id}"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  cidr_blocks       = [ "${split(",", var.ssh_access_list)}" ]
}

# permit ssh from the access list
resource "aws_security_group_rule" "secure_permit_123" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.secure.id}"
  protocol                 = "udp"
  from_port                = "123"
  to_port                  = "123"
  source_security_group_id = "${aws_security_group.compute.id}"
}

# permit etcd client from the access list
resource "aws_security_group_rule" "secure_permit_2379" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.secure.id}"
  protocol                 = "tcp"
  from_port                = "2379"
  to_port                  = "2379"
  source_security_group_id = "${aws_security_group.compute.id}"
}

# permit etcd peer from the access list
resource "aws_security_group_rule" "secure_permit_2380" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.secure.id}"
  protocol                 = "tcp"
  from_port                = "2380"
  to_port                  = "2380"
  source_security_group_id = "${aws_security_group.compute.id}"
}

# permit vault from the access list
resource "aws_security_group_rule" "secure_permit_8200" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.secure.id}"
  protocol                 = "tcp"
  from_port                = "8200"
  to_port                  = "8200"
  source_security_group_id = "${aws_security_group.compute.id}"
}
