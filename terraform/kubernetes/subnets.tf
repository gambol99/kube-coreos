#
# Notes:
#  We have four subnets
#   compute:    the kubernetes worker nodes
#   secure:     the etcd and vault subnets
#

#
#### [Compute Subnets] ####
#
resource "aws_subnet" "compute_subnets" {
  count             = 3
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${lookup(var.compute_subnets, \"az${count.index}_cidr\")}"
  availability_zone = "${lookup(var.compute_subnets, \"az${count.index}_zone\")}"

  tags {
    Name = "${var.environment}-compute-az${count.index}"
    Env  = "${var.environment}"
    Role = "compute"
  }
}

#
## Route Association for Compute Subnets
#
resource "aws_route_table_association" "compute_routes" {
  count          = 3
  subnet_id      = "${element(aws_subnet.compute_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.default.id}"
}

#
#### [Secure Subnets] ####
#
resource "aws_subnet" "secure_subnets" {
  count             = 3
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${lookup(var.secure_subnets, \"az${count.index}_cidr\")}"
  availability_zone = "${lookup(var.secure_subnets, \"az${count.index}_zone\")}"

  tags {
    Name = "${var.environment}-secure-az${count.index}"
    Env  = "${var.environment}"
		Role = "secure"
  }
}

#
## Route Association for Secure Subnets
#
resource "aws_route_table_association" "secure_routes" {
  count          = 3
  subnet_id      = "${element(aws_subnet.secure_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.default.id}"
}
