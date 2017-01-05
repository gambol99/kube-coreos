
## Public NAT security group
resource "aws_security_group" "public" {
  name        = "${var.environment}-public"
  description = "Public NAT Security Group for ${var.environment} environment"
  vpc_id      = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.environment}-public"
    Env  = "${var.environment}"
		Role = "public"
  }
}

## Compute security group
resource "aws_security_group" "compute" {
  name        = "${var.environment}-compute"
  description = "Compute Security Group for ${var.environment} environment"
  vpc_id      = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.environment}-compute"
    Env  = "${var.environment}"
		Role = "compute"
  }
}

## Secure security group
resource "aws_security_group" "secure" {
  name        = "${var.environment}-secure"
  description = "Secure Security Group for ${var.environment} environment"
  vpc_id      = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.environment}-secure"
    Env  = "${var.environment}"
		Role = "secure"
  }
}

## ELB Security Group
resource "aws_security_group" "elb" {
  name        = "${var.environment}-elb"
  description = "ELB Security Group for ${var.environment} environment"
  vpc_id      = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.environment}-elb"
    Env  = "${var.environment}"
    Role = "load-balancers"
  }
}

## Management Security Group
resource "aws_security_group" "mgmt" {
  name        = "${var.environment}-mgmt"
  description = "Management Security Group for ${var.environment} environment"
  vpc_id      = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.environment}-mgmt"
    Env  = "${var.environment}"
    Role = "mangement"
  }
}
