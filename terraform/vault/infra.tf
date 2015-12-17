#
# Infrastructure Related
#

#
## The AWS Provider
#
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

#
## VPC
#
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags {
    Name = "${var.environment}-vault-infra"
    Env  = "${var.environment}"
    Role = "vault"
  }
}

#
## Default Environment Keypair
#
resource "aws_key_pair" "default" {
  key_name = "${var.environment}-key"
  public_key = "${file(\"../secrets/${var.environment}/${var.environment}.pub\")}"
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

#
# ========= SUBNETS AND ROUTING ASSOCIATIONS ========
#

#
## Vault Subnets
#
resource "aws_subnet" "vault_subnets" {
  count             = 3
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${lookup(var.vault_subnets, \"az${count.index}_cidr\")}"
  availability_zone = "${lookup(var.vault_subnets, \"az${count.index}_zone\")}"

  tags {
    Name = "${var.environment}-vault-az${count.index}"
    Env  = "${var.environment}"
  }
}

#
## Vault IAM Role
#
resource "aws_iam_role" "vault" {
  name               = "${var.environment}-vault-role"
  path               = "/"
  assume_role_policy = "${file(\"vault/assets/iam/assume-role.json\")}"
}


#
## Route Association for Compute Subnets
#
resource "aws_route_table_association" "vault_routes" {
  count          = 3
  subnet_id      = "${element(aws_subnet.vault_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.default.id}"
}

#
## Vault security group
#
resource "aws_security_group" "vault_sg" {
  name        = "${var.environment}-vault-sg"
  description = "Vault Security Group (${var.environment})"
  vpc_id      = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.environment}-vault-sg"
    Env  = "${var.environment}"
  }

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = [ "${split(\",\", var.ssh_access_list)}" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
