#
# Notes:
#  We have four subnets
#   compute:    the kubernetes compute layer
#   secure:     the kubernetes master layer
#   elb:        the elb subnets
#   nat:        the subnets for the nat gateways
#   mgmt:       the subnet for the management layer
#

### [Nat Subnets] ####
resource "aws_subnet" "nat_subnets" {
  count             = "${length(keys(var.nat_subnets))/2}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${lookup(var.nat_subnets, "az${count.index}_cidr")}"
  availability_zone = "${lookup(var.nat_subnets, "az${count.index}_zone")}"

  tags {
    Env               = "${var.environment}"
    KubernetesCluster = "${var.environment}"
    Name              = "${var.environment}-nat-az${count.index}"
  	Role              = "nat"
  }
}

## Route Association for NAT Subnets
resource "aws_route_table_association" "nat" {
  count          = "${length(keys(var.nat_subnets))/2}"
  subnet_id      = "${element(aws_subnet.nat_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.nat_routes.id}"
}

#### [Compute Subnets] ####
resource "aws_subnet" "compute_subnets" {
  count             = "${length(keys(var.compute_subnets))/2}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${lookup(var.compute_subnets, "az${count.index}_cidr")}"
  availability_zone = "${lookup(var.compute_subnets, "az${count.index}_zone")}"

  tags {
    Env               = "${var.environment}"
    KubernetesCluster = "${var.environment}"
    Name              = "${var.environment}-compute-az${count.index}"
    Role              = "compute"
  }
}

## Route Association for Compute Subnets
resource "aws_route_table_association" "compute_routes" {
  count          = "${length(keys(var.compute_subnets))/2}"
  subnet_id      = "${element(aws_subnet.compute_subnets.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.zone_routes.*.id, count.index)}"
}

#### [ELB Subnets] ####
resource "aws_subnet" "elb_subnets" {
  count             = "${length(keys(var.elb_subnets))/2}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${lookup(var.elb_subnets, "az${count.index}_cidr")}"
  availability_zone = "${lookup(var.elb_subnets, "az${count.index}_zone")}"

  tags {
    "Env"                             = "${var.environment}"
    "KubernetesCluster"               = "${var.environment}"
    "Name"                            = "${var.environment}-elb-az${count.index}"
  	"Role"                            = "elb"
    "kubernetes.io/role/internal-elb" = "true"
    "kubernetes.io/role/elb"          = "true"
  }
}

## Route Association for ELB Subnets
resource "aws_route_table_association" "elb_routes" {
  count          = "${length(keys(var.elb_subnets))/2}"
  subnet_id      = "${element(aws_subnet.elb_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.nat_routes.id}"
}

#### [Secure Subnets] ####
resource "aws_subnet" "secure_subnets" {
  count             = "${length(keys(var.secure_subnets))/2}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${lookup(var.secure_subnets, "az${count.index}_cidr")}"
  availability_zone = "${lookup(var.secure_subnets, "az${count.index}_zone")}"

  tags {
    Env               = "${var.environment}"
    KubernetesCluster = "${var.environment}"
    Name              = "${var.environment}-secure-az${count.index}"
  	Role              = "secure"
  }
}

## Route Association for Secure Subnets
resource "aws_route_table_association" "secure_routes" {
  count          = "${length(keys(var.secure_subnets))/2}"
  subnet_id      = "${element(aws_subnet.secure_subnets.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.zone_routes.*.id, count.index)}"
}

#### [Management Subnets] ####
resource "aws_subnet" "mgmt_subnets" {
  count             = "${length(keys(var.mgmt_subnets))/2}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${lookup(var.mgmt_subnets, "az${count.index}_cidr")}"
  availability_zone = "${lookup(var.mgmt_subnets, "az${count.index}_zone")}"

  tags {
    Env               = "${var.environment}"
    KubernetesCluster = "${var.environment}"
    Name              = "${var.environment}-mgmt-az${count.index}"
  	Role              = "mgmt"
  }
}

## Route Association for mgmt Subnets
resource "aws_route_table_association" "mgmt_routes" {
  count          = "${length(keys(var.mgmt_subnets))/2}"
  subnet_id      = "${element(aws_subnet.mgmt_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.nat_routes.id}"
}

## Add default route to NAT Gateways
resource "aws_route" "nat_default_routes" {
  depends_on    = [ "aws_nat_gateway.gateways" ]

  count                  = "${length(keys(var.nat_subnets))/2}"
  route_table_id         = "${element(aws_route_table.zone_routes.*.id, count.index)}"
  nat_gateway_id         = "${element(aws_nat_gateway.gateways.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
}
