#
## KubeDNS Deployment
#
resource "aws_s3_bucket_object" "kubedns_deployment" {
  bucket     = "${var.secrets_bucket_name}"
  key        = "addons/kubedns/deployment.yml"
  content    = "${file("${path.module}/assets/addons/kubedns/deployment.yml")}"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.caller.account_id}:key/${var.kms_master_id}"
}

#
## Dashboard Deployment
#
resource "aws_s3_bucket_object" "kube_dashbord_deployment" {
  bucket     = "${var.secrets_bucket_name}"
  key        = "addons/dashboard/deployment.yml"
  content    = "${file("${path.module}/assets/addons/dashboard/deployment.yml")}"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.caller.account_id}:key/${var.kms_master_id}"
}

#
## Calico Deployment
#
data "template_file" "calico_deployment" {
  template = "${file("${path.module}/assets/addons/calico/deployment.yml")}"

  vars = {
    flannel_memberlist  = "${join(",", formatlist("https://%s:2379", values(var.secure_nodes)))}"
  }
}

resource "aws_s3_bucket_object" "calico_deployment" {
  bucket     = "${var.secrets_bucket_name}"
  key        = "addons/calico/deployment.yml"
  content    = "${data.template_file.calico_deployment.rendered}"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.caller.account_id}:key/${var.kms_master_id}"
}
