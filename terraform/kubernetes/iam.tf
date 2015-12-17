#
# IAM Roles
#

#
## Compute IAM Role
#
resource "aws_iam_role" "compute" {
  name               = "${var.environment}-compute-role"
  path               = "/"
  assume_role_policy = "${file(\"kubernetes/assets/iam/assume-role.json\")}"
}

#
## Kube IAM Role
#
resource "aws_iam_role" "kube" {
  name               = "${var.environment}-kube-role"
  path               = "/"
  assume_role_policy = "${file(\"kubernetes/assets/iam/assume-role.json\")}"
}

#
## Secure IAM Role
#
resource "aws_iam_role" "secure" {
  name               = "${var.environment}-etcd-role"
  path               = "/"
  assume_role_policy = "${file(\"kubernetes/assets/iam/assume-role.json\")}"
}
