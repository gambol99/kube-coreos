#
## Kubernetes manifests
#

#resource "aws_s3_bucket_object" "kube_proxy" {
#  bucket     = "${aws_s3_bucket.secrets.bucket}"
#  etag       = "${md5(file("kubernetes/assets/manifests/kube-proxy.yml"))}"
#  key        = "manifests/compute/kube-proxy.yml"
#  source     = "kubernetes/assets/manifests/kube-proxy.yml"
#  #kms_key_id = "arn:aws:kms:${var.aws_region}:${var.aws_account}:key/${var.kms_master_id}"
#}
#
#resource "aws_s3_bucket_object" "kube_apiserver" {
#  bucket     = "${aws_s3_bucket.secrets.bucket}"
#  etag       = "${md5(file("kubernetes/assets/manifests/kube-apiserver.yml"))}"
#  key        = "manifests/secure/kube-apiserver.yml"
#  source     = "kubernetes/assets/manifests/kube-apiserver.yml"
#}
#
#resource "aws_s3_bucket_object" "kube_controller_manager" {
#  bucket     = "${aws_s3_bucket.secrets.bucket}"
#  etag       = "${md5(file("kubernetes/assets/manifests/kube-controller-manager.yml"))}"
#  key        = "manifests/secure/kube-controller-manager.yml"
#  source     = "kubernetes/assets/manifests/kube-controller-manager.yml"
#}
#
#resource "aws_s3_bucket_object" "kube_scheduler" {
#  bucket     = "${aws_s3_bucket.secrets.bucket}"
#  etag       = "${md5(file("kubernetes/assets/manifests/kube-scheduler.yml"))}"
#  key        = "manifests/secure/kube-scheduler.yml"
#  source     = "kubernetes/assets/manifests/kube-scheduler.yml"
#}
#
##
### Kuberneres Addon Components
##
#resource "aws_s3_bucket_object" "kube_dns_deployment" {
#  bucket     = "${aws_s3_bucket.secrets.bucket}"
#  etag       = "${md5(file("kubernetes/assets/manifests/addons/kube-dns-deployment.yml"))}"
#  key        = "manifests/addons/kube-dns-deployment.yml"
#  source     = "kubernetes/assets/manifests/addons/kube-dns-deployment.yml"
#}
#
#resource "aws_s3_bucket_object" "kube_dns_service" {
#  bucket     = "${aws_s3_bucket.secrets.bucket}"
#  etag       = "${md5(file("kubernetes/assets/manifests/addons/kube-dns-service.yml"))}"
#  key        = "manifests/addons/kube-dns-service.yml"
#  source     = "kubernetes/assets/manifests/addons/kube-dns-service.yml"
#}
