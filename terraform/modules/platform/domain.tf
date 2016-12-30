
## Route53 Public Domain
resource "aws_route53_zone" "public" {
  name            = "${var.public_zone_name}"
  comment         = "Kubernetes Public Domain for ${var.environment} environment"

  tags {
    Name        = "${var.public_zone_name}"
    Environment = "${var.environment}"
    Role        = "dns-zone"
  }
}

## Route53 Private Domain
resource "aws_route53_zone" "private" {
  name            = "${var.private_zone_name}"
  comment         = "Kubernetes Private Domain for ${var.environment} environment"
  vpc_id          = "${aws_vpc.vpc.id}"

  tags {
    Name        = "${var.private_zone_name}"
    Environment = "${var.environment}"
    Role        = "dns-zone"
  }
}
