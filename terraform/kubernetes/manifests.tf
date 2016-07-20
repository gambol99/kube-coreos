#
## Kubernetes manifests
#

resource "aws_s3_bucket_object" "calico_ns" {
  key        = "manifests/calico-ns.yml"
  bucket     = "${aws_s3_bucket.secrets.bucket}"
  source     = "${file(\"kubernetes/assets/calico-ns.yml\")}"
  kms_key_id = "${var.kms_master_arn}"
}

resource "aws_s3_bucket_object" "kube_proxy" {
  key        = "manifests/kube-proxy.yml"
  bucket     = "${aws_s3_bucket.secrets.bucket}"
  source     = "${file(\"kubernetes/assets/kube-proxy.yml\")}"
  kms_key_id = "${var.kms_master_arn}"
}

resource "aws_s3_bucket_object" "kube_apiserver" {
  key        = "manifests/kube-apiserver.yml"
  bucket     = "${aws_s3_bucket.secrets.bucket}"
  source     = "${file(\"kubernetes/assets/kube-apiserver.yml\")}"
  kms_key_id = "${var.kms_master_arn}"
}

resource "aws_s3_bucket_object" "kube_controller_manager" {
  key        = "manifests/kube-controller-manager.yml"
  bucket     = "${aws_s3_bucket.secrets.bucket}"
  source     = "${file(\"kubernetes/assets/kube-controller-manager.yml\")}"
  kms_key_id = "${var.kms_master_arn}"
}

resource "aws_s3_bucket_object" "kube_scheduler" {
  key        = "manifests/kube-scheduler.yml"
  bucket     = "${aws_s3_bucket.secrets.bucket}"
  source     = "${file(\"kubernetes/assets/kube-scheduler.yml\")}"
  kms_key_id = "${var.kms_master_arn}"
}

resource "aws_s3_bucket_object" "kube_dns" {
  key        = "manifests/kube-dns.yml"
  bucket     = "${aws_s3_bucket.secrets.bucket}"
  source     = "${file(\"kubernetes/assets/kube-dns.yml\")}"
  kms_key_id = "${var.kms_master_arn}"
}
