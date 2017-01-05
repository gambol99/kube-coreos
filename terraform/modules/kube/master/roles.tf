#
## Iam Roles & Policies
#

## IAM Role
resource "aws_iam_role" "secure" {
  name               = "${var.environment}-secure-role"
  assume_role_policy = "${file("${path.module}/assets/iam/assume-role.json")}"
}

## Role Policy Template
data "template_file" "secure_policy" {
  template = "${file("${path.module}/assets/iam/secure-role.json")}"
  vars = {
    aws_region          = "${var.aws_region}"
    environment         = "${var.environment}"
    kms_master_id       = "${var.kms_master_id}"
    secrets_bucket_name = "${var.secrets_bucket_name}"
  }
}

## Policy IAM Policy
resource "aws_iam_policy" "secure" {
  name        = "${var.environment}-secure"
  description = "IAM Policy for Secure nodes in ${var.environment} environment"
  policy      = "${data.template_file.secure_policy.rendered}"
}

# Role Attachment
resource "aws_iam_role_policy_attachment" "secure" {
  policy_arn = "${aws_iam_policy.secure.arn}"
  role       = "${aws_iam_role.secure.name}"
}
