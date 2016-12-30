#
## Iam Roles & Policies
#

## Compute IAM Role
resource "aws_iam_role" "compute" {
  name               = "${var.environment}-compute-role"
  path               = "/"
  assume_role_policy = "${file("${path.module}/assets/iam/assume-role.json")}"
}

## Compute Role Policy Template
data "template_file" "compute_policy" {
  template = "${file("${path.module}/assets/iam/compute-role.json")}"
  vars = {
    aws_region          = "${var.aws_region}"
    environment         = "${var.environment}"
    kms_master_id       = "${var.kms_master_id}"
    secrets_bucket_name = "${var.secrets_bucket_name}"
  }
}

# Compute Policy IAM Policy
resource "aws_iam_policy" "compute" {
  name        = "${var.environment}-compute"
  description = "IAM Policy for Compute nodes in ${var.environment} environment"
  policy      = "${data.template_file.compute_policy.rendered}"
}

# Compute Role Attachment
resource "aws_iam_role_policy_attachment" "compute" {
  policy_arn = "${aws_iam_policy.compute.arn}"
  role       = "${aws_iam_role.compute.name}"
}
