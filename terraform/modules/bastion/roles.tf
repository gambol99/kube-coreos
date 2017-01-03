
## IAM Role
resource "aws_iam_role" "bastion" {
  name               = "${var.environment}-bastion-role"
  assume_role_policy = "${file("${path.module}/assets/iam/assume-role.json")}"
}

## Role Policy Template
data "template_file" "bastion_policy" {
  template = "${file("${path.module}/assets/iam/bastion.json")}"
  vars = {
    aws_region          = "${var.aws_region}"
    environment         = "${var.environment}"
    kms_master_id       = "${var.kms_master_id}"
    secrets_bucket_name = "${var.secrets_bucket_name}"
  }
}

## Policy IAM Policy
resource "aws_iam_policy" "bastion" {
  name        = "${var.environment}-bastion"
  description = "IAM Policy for Bastion nodes in ${var.environment} environment"
  policy      = "${data.template_file.bastion_policy.rendered}"
}

# Role Attachment
resource "aws_iam_role_policy_attachment" "bastion" {
  policy_arn = "${aws_iam_policy.bastion.arn}"
  role       = "${aws_iam_role.bastion.name}"
}
