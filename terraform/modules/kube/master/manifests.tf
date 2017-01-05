#
## Kubernetes manifests
#

data "gotemplate_file" "kube_addons" {
  template = "${file("${path.module}/assets/manifests/kube-addons.yml")}"
  vars = {
    aws_region               = "${var.aws_region}"
    enable_calico            = "${var.enable_calico}"
    kmsctl_image             = "${var.kmsctl_image}"
    secrets_bucket_name      = "${var.secrets_bucket_name}"
  }
}

data "gotemplate_file" "kube_apiserver" {
  template = "${file("${path.module}/assets/manifests/kube-apiserver.yml")}"
  vars = {
    aws_region               = "${var.aws_region}"
    etcd_memberlist          = "${join(",", formatlist("https://%s:2379", values(var.secure_nodes)))}"
    kmsctl_image             = "${var.kmsctl_image}"
    kube_auth_image          = "${var.kube_auth_image}"
    kubeapi_count            = "${length(values(var.secure_nodes))}"
    kubernetes_image         = "${var.kubernetes_image}"
    secrets_bucket_name      = "${var.secrets_bucket_name}"
  }
}

data "gotemplate_file" "kube_controller_manager" {
  template = "${file("${path.module}/assets/manifests/kube-controller-manager.yml")}"
  vars = {
    aws_region               = "${var.aws_region}"
    kmsctl_image             = "${var.kmsctl_image}"
    kubernetes_image         = "${var.kubernetes_image}"
    secrets_bucket_name      = "${var.secrets_bucket_name}"
  }
}

data "gotemplate_file" "kube_proxy" {
  template = "${file("${path.module}/assets/manifests/kube-proxy.yml")}"
  vars = {
    aws_region               = "${var.aws_region}"
    flannel_cidr             = "${var.flannel_cidr}"
    kmsctl_image             = "${var.kmsctl_image}"
    kubeapi_dns_name         = "${var.kubeapi_internal_dns}.${var.private_zone_name}"
    kubernetes_image         = "${var.kubernetes_image}"
    secrets_bucket_name      = "${var.secrets_bucket_name}"
  }
}

data "gotemplate_file" "kube_scheduler" {
  template = "${file("${path.module}/assets/manifests/kube-scheduler.yml")}"
  vars = {
    aws_region               = "${var.aws_region}"
    kmsctl_image             = "${var.kmsctl_image}"
    kubernetes_image         = "${var.kubernetes_image}"
    secrets_bucket_name      = "${var.secrets_bucket_name}"
  }
}


##
### S3 Uploads
##
resource "aws_s3_bucket_object" "kube_addons" {
  bucket     = "${var.secrets_bucket_name}"
  key        = "manifests/secure/kube-addons.yml"
  content    = "${data.gotemplate_file.kube_addons.rendered}"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.caller.account_id}:key/${var.kms_master_id}"
}

resource "aws_s3_bucket_object" "kube_proxy" {
  bucket     = "${var.secrets_bucket_name}"
  key        = "manifests/common/kube-proxy.yml"
  content    = "${data.gotemplate_file.kube_proxy.rendered}"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.caller.account_id}:key/${var.kms_master_id}"
}

resource "aws_s3_bucket_object" "kube_apiserver" {
  bucket     = "${var.secrets_bucket_name}"
  key        = "manifests/secure/kube-apiserver.yml"
  content    = "${data.gotemplate_file.kube_apiserver.rendered}"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.caller.account_id}:key/${var.kms_master_id}"
}

resource "aws_s3_bucket_object" "kube_controller_manager" {
  bucket     = "${var.secrets_bucket_name}"
  key        = "manifests/secure/kube-controller-manager.yml"
  content    = "${data.gotemplate_file.kube_controller_manager.rendered}"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.caller.account_id}:key/${var.kms_master_id}"
}

resource "aws_s3_bucket_object" "kube_scheduler" {
  bucket     = "${var.secrets_bucket_name}"
  key        = "manifests/secure/kube-scheduler.yml"
  content    = "${data.gotemplate_file.kube_scheduler.rendered}"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${data.aws_caller_identity.caller.account_id}:key/${var.kms_master_id}"
}
