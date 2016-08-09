
#
## Public security group
#
resource "aws_security_group" "public" {
  name        = "${var.environment}-public"
  description = "Public Security Group (${var.environment})"
  vpc_id      = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.environment}-public"
    Env  = "${var.environment}"
		Role = "public"
  }
}

#
## Compute security group
#
resource "aws_security_group" "compute" {
  name        = "${var.environment}-compute"
  description = "Compute Security Group (${var.environment})"
  vpc_id      = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.environment}-compute"
    Env  = "${var.environment}"
		Role = "compute"
  }
}

#
## Secure security group
#
resource "aws_security_group" "secure" {
  name        = "${var.environment}-secure"
  description = "Secure Security Group (${var.environment})"
  vpc_id      = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.environment}-secure"
    Env  = "${var.environment}"
		Role = "secure"
  }
}

#
## Secure ELB Security Group
#
resource "aws_security_group" "secure_elb" {
  depends_on  = [ "aws_security_group.secure" ]
  name        = "${var.environment}-secure-elb"
  description = "Secure ELB Security Group (${var.environment})"
  vpc_id      = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.environment}-secure-elb"
    Env  = "${var.environment}"
    Role = "secure"
  }
}

#
## Kube Internal API ELB Security Group
#
resource "aws_security_group" "kube_elb" {
  name        = "${var.environment}-kube-elb"
  description = "Internal Kube API ELB Security Group (${var.environment})"
  vpc_id      = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.environment}-kube-elb"
    Env  = "${var.environment}"
    Role = "kubeapi"
  }
}

#
## Kube External API ELB Security Group
#
resource "aws_security_group" "kubeapi_elb" {
  name        = "${var.environment}-kubeapi-elb"
  description = "External Kube API ELB Security Group (${var.environment})"
  vpc_id      = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.environment}-kubeapi-elb"
    Env  = "${var.environment}"
    Role = "kubeapi"
  }
}
