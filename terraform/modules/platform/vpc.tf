#
# Infrastructure Related
#

## VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags {
    Name = "${var.environment}-kube"
    Env  = "${var.environment}"
    Role = "kubernetes"
  }
}

## DHCP Options for VPC
resource "aws_vpc_dhcp_options" "default" {
  domain_name         = "${var.aws_region}.compute.internal"
  domain_name_servers = [ "AmazonProvidedDNS" ]
  tags {
    Name = "${var.environment}-dhcp-options"
    Env  = "${var.environment}"
    Role = "dhcp"
  }
}

## Associate of the DHCP Options to the VPC
resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${aws_vpc.vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.default.id}"
}

## Internet Gateway
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${var.environment}-gateway"
    Env  = "${var.environment}"
    Role = "internet-gw"
  }
}

## NAT EIP
resource "aws_eip" "nat_eips" {
  count   = "${length(keys(var.nat_subnets))/2}"
  vpc     = true
}

## Nat Routing tables used by the nat gateways
resource "aws_route_table" "nat_routes" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name              = "${var.environment}-nat-rt"
    Env               = "${var.environment}"
    KubernetesCluster = "${var.environment}"
    Role              = "nat-route-az${count.index}"
  }
}

## Availability Routing Tables, used by add subnets in the AZ
resource "aws_route_table" "zone_routes" {
  count  = "${length(keys(var.nat_subnets))/2}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Env               = "${var.environment}"
    KubernetesCluster = "${var.environment}"
    Name              = "${var.environment}-zone-rt-az${count.index}"
    Role              = "zone-routes-az${count.index}"
  }
}

## Managed NAT Gateways
resource "aws_nat_gateway" "gateways" {
  depends_on = [ "aws_internet_gateway.default", "aws_subnet.nat_subnets" ]

  count         = "${length(keys(var.nat_subnets))/2}"
  allocation_id = "${element(aws_eip.nat_eips.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.nat_subnets.*.id, count.index)}"
}
