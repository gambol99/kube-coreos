#
## Kubernetes manifests
#

resource "aws_s3_bucket_object" "kube_proxy" {
  key        = "manifests/compute/kube-proxy.yml"
  bucket     = "${aws_s3_bucket.secrets.bucket}"
  source     = "kubernetes/assets/manifests/kube-proxy.yml"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${var.aws_account}:key/${var.kms_master_id}"
}

resource "aws_s3_bucket_object" "kube_apiserver" {
  key        = "manifests/secure/kube-apiserver.yml"
  bucket     = "${aws_s3_bucket.secrets.bucket}"
  source     = "kubernetes/assets/manifests/kube-apiserver.yml"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${var.aws_account}:key/${var.kms_master_id}"
}

resource "aws_s3_bucket_object" "kube_controller_manager" {
  key        = "manifests/secure/kube-controller-manager.yml"
  bucket     = "${aws_s3_bucket.secrets.bucket}"
  source     = "kubernetes/assets/manifests/kube-controller-manager.yml"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${var.aws_account}:key/${var.kms_master_id}"
}

resource "aws_s3_bucket_object" "kube_scheduler" {
  key        = "manifests/secure/kube-scheduler.yml"
  bucket     = "${aws_s3_bucket.secrets.bucket}"
  source     = "kubernetes/assets/manifests/kube-scheduler.yml"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${var.aws_account}:key/${var.kms_master_id}"
}

#
## Kuberneres Addon Components
#

resource "aws_s3_bucket_object" "kube_dns_deployment" {
  key        = "manifests/addons/kube-dns.yml"
  bucket     = "${aws_s3_bucket.secrets.bucket}"
  source     = "kubernetes/assets/manifests/addons/kube-dns.yml"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${var.aws_account}:key/${var.kms_master_id}"
}

resource "aws_s3_bucket_object" "kube_dns_service" {
  key        = "manifests/addons/kube-dns-service.yml"
  bucket     = "${aws_s3_bucket.secrets.bucket}"
  source     = "kubernetes/assets/manifests/addons/kube-dns-service.yml"
  kms_key_id = "arn:aws:kms:${var.aws_region}:${var.aws_account}:key/${var.kms_master_id}"
}
