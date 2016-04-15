#
# Notes:
#  We have four subnets
#   compute:    the kubernetes worker nodes
#   public:     the public facing elb and nat gateways
#   secure:     the etcd and vault subnets
#

#
#### [Public Subnets] ####
#
resource "aws_subnet" "public_subnets" {
  count             = 3
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${lookup(var.public_subnets, \"az${count.index}_cidr\")}"
  availability_zone = "${lookup(var.public_subnets, \"az${count.index}_zone\")}"

  tags {
    Name = "${var.environment}-public-az${count.index}"
    Env  = "${var.environment}"
    Role = "public"
  }
}

#
## Public Routing Table
#
resource "aws_route_table" "public" {
  count  = 3
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.environment}-public-${lookup(var.public_subnets, \"az${count.index}_zone\")}"
    Env  = "${var.environment}"
    Role = "public"
  }
}

#
## Route Association for Public Subnets
#
resource "aws_route_table_association" "public_routes" {
  count          = 3
  subnet_id      = "${element(aws_subnet.public_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.default.id}"
}


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
#### Compute Routing Table
#
resource "aws_route_table" "compute" {
  count  = 3
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.environment}-compute-${lookup(var.compute_subnets, \"az${count.index}_zone\")}"
    Env  = "${var.environment}"
    Role = "compute"
  }
}

#
## Route Association for Compute Subnets
#
resource "aws_route" "compute_nat_routes" {
  count                     = 3
  destination_cidr_block    = "0.0.0.0/0"
  route_table_id            = "${element(aws_route_table.compute.*.id, count.index)}"
  nat_gateway_id            = "${element(aws_nat_gateway.nat.*.id, count.index)}"
}

#
## Route Association for Compute Subnets
#
resource "aws_route_table_association" "compute_routes" {
  count          = 3
  subnet_id      = "${element(aws_subnet.compute_subnets.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.compute.*.id, count.index)}"
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
