#
# Infrastructure Related
#

#
## VPC
#
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags {
    Name = "${var.environment}-infra"
    Env  = "${var.environment}"
    Role = "kubernetes"
  }
}

#
## DHCP Options for VPC
#
resource "aws_vpc_dhcp_options" "default" {
  domain_name         = "${var.aws_region}.compute.internal"
  domain_name_servers = [ "AmazonProvidedDNS" ]
  tags {
    Name = "${var.environment}-dhcp-options"
    Env  = "${var.environment}"
  }
}

#
## Associate of the DHCP Options to the VPC
#
resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${aws_vpc.vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.default.id}"
}

#
## Internet Gateway
#
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${var.environment}-gateway"
    Env  = "${var.environment}"
    Role = "internet-gw"
  }
}

#
## VPC Routing Table
#
resource "aws_route_table" "default" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name = "${var.environment}-route-table"
    Env  = "${var.environment}"
    Role = "default-routes"
  }
}
