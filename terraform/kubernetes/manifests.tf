#
## Kubernetes manifests
#

data "template_file" "kube_apiserver" {
  template = "${file("kubernetes/assets/manifests/kube-apiserver.yml")}"
  vars = {
    kubernetes_service_range = "${var.kubernetes_service_range}"
    kubernetes_image         = "${var.kubernetes_image}"
    kubernetes_version       = "${var.kubernetes_version}"
  }
}

data "template_file" "kube_controller_manager" {
  template = "${file("kubernetes/assets/manifests/kube-controller-manager.yml")}"
  vars = {
    kubernetes_service_range = "${var.kubernetes_service_range}"
    kubernetes_image         = "${var.kubernetes_image}"
    kubernetes_version       = "${var.kubernetes_version}"
  }
}

data "template_file" "kube_proxy" {
  template = "${file("kubernetes/assets/manifests/kube-proxy.yml")}"
  vars = {
    kube_elb_dns_name        = "kube.${var.dns_zone_name}"
    kubernetes_service_range = "${var.kubernetes_service_range}"
    kubernetes_image         = "${var.kubernetes_image}"
    kubernetes_version       = "${var.kubernetes_version}"
  }
}

data "template_file" "kube_scheduler" {
  template = "${file("kubernetes/assets/manifests/kube-scheduler.yml")}"
  vars = {
    kubernetes_service_range = "${var.kubernetes_service_range}"
    kubernetes_image         = "${var.kubernetes_image}"
    kubernetes_version       = "${var.kubernetes_version}"
  }
}

data "template_file" "kube_dns_deployment" {
  template = "${file("kubernetes/assets/manifests/addons/kube-dns-deployment.yml")}"
  vars = {
    kubernetes_service_range = "${var.kubernetes_service_range}"
    kubernetes_image         = "${var.kubernetes_image}"
    kubernetes_version       = "${var.kubernetes_version}"
  }
}

data "template_file" "kube_dns_service" {
  template = "${file("kubernetes/assets/manifests/addons/kube-dns-service.yml")}"
  vars = {
    kubernetes_service_range = "${var.kubernetes_service_range}"
    kubernetes_image         = "${var.kubernetes_image}"
    kubernetes_version       = "${var.kubernetes_version}"
  }
}

#
## S3 Uploads
#
resource "aws_s3_bucket_object" "kube_proxy" {
  bucket     = "${aws_s3_bucket.secrets.bucket}"
  key        = "manifests/compute/kube-proxy.yml"
  content    = "${data.template_file.kube_proxy.rendered}"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${var.aws_account}:key/${var.kms_master_id}"
}

resource "aws_s3_bucket_object" "kube_apiserver" {
  bucket     = "${aws_s3_bucket.secrets.bucket}"
  key        = "manifests/secure/kube-apiserver.yml"
  content    = "${data.template_file.kube_apiserver.rendered}"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${var.aws_account}:key/${var.kms_master_id}"
}

resource "aws_s3_bucket_object" "kube_controller_manager" {
  bucket     = "${aws_s3_bucket.secrets.bucket}"
  key        = "manifests/secure/kube-controller-manager.yml"
  content    = "${data.template_file.kube_controller_manager.rendered}"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${var.aws_account}:key/${var.kms_master_id}"
}

resource "aws_s3_bucket_object" "kube_scheduler" {
  bucket     = "${aws_s3_bucket.secrets.bucket}"
  key        = "manifests/secure/kube-scheduler.yml"
  content    = "${data.template_file.kube_scheduler.rendered}"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${var.aws_account}:key/${var.kms_master_id}"
}

#
## Kuberneres Addon Components
#
resource "aws_s3_bucket_object" "kube_dns_deployment" {
  bucket     = "${aws_s3_bucket.secrets.bucket}"
  key        = "manifests/addons/kube-dns-deployment.yml"
  content    = "${data.template_file.kube_dns_deployment.rendered}"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${var.aws_account}:key/${var.kms_master_id}"
}

resource "aws_s3_bucket_object" "kube_dns_service" {
  bucket     = "${aws_s3_bucket.secrets.bucket}"
  key        = "manifests/addons/kube-dns-service.yml"
  content    = "${data.template_file.kube_dns_service.rendered}"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${var.aws_account}:key/${var.kms_master_id}"
}
