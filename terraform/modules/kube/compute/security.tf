
#
## Ingress Secure
#

## Permit Kubernetes Exec client from secure api
resource "aws_security_group_rule" "compute_permit_10250" {
  type                     = "ingress"
  security_group_id        = "${var.compute_sg}"
  protocol                 = "tcp"
  from_port                = "10250"
  to_port                  = "10250"
  source_security_group_id = "${var.secure_sg}"
}
