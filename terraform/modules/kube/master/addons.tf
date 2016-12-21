#
## Kuberneres Addon Components
#

resource "aws_s3_bucket_object" "kube_dns_deployment" {
  bucket     = "${var.secrets_bucket_name}"
  key        = "addons/kubedns/deployment.yml"
  content    = "${file("${path.module}/assets/addons/kubedns/deployment.yml")}"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.caller.account_id}:key/${var.kms_master_id}"
}

resource "aws_s3_bucket_object" "kube_dns_service" {
  bucket     = "${var.secrets_bucket_name}"
  key        = "addons/kubedns/service.yml"
  content    = "${file("${path.module}/assets/addons/kubedns/service.yml")}"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.caller.account_id}:key/${var.kms_master_id}"
}

resource "aws_s3_bucket_object" "kube_dns_service_account" {
  bucket     = "${var.secrets_bucket_name}"
  key        = "addons/kubedns/service-account.yml"
  content    = "${file("${path.module}/assets/addons/kubedns/service-account.yml")}"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.caller.account_id}:key/${var.kms_master_id}"
}
