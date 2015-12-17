
#
## Kubernetes
#
module "kube" {
  source                   = "./kubernetes"
  aws_access_key           = "${var.aws_access_key}"
  aws_region               = "${var.aws_region}"
  aws_secret_key           = "${var.aws_secret_key}"
  compute_asg_grace_period = "${var.compute_asg_grace_period}"
  compute_asg_max          = "${var.compute_asg_max}"
  compute_asg_min          = "${var.compute_asg_min}"
  compute_flavor           = "${var.compute_flavor}"
  coreos_image             = "${var.coreos_image}"
  dns_zone_name            = "${var.dns_zone_name}"
  environment              = "${var.environment}"
  etcd_discovery_md5       = "${var.etcd_discovery_md5}"
  etcd_discovery_url       = "${var.etcd_discovery_url}"
  kms_master_id            = "${var.kms_master_id}"
  kubeapi_access_list      = "${var.kubeapi_access_list}"
  secrets_bucket_name      = "${var.secrets_bucket_name}"
  secure_asg_max           = "${var.secure_asg_max}"
  secure_asg_min           = "${var.secure_asg_min}"
  secure_flavor            = "${var.secure_flavor}"
  ssh_access_list          = "${var.ssh_access_list}"
  terraform_bucket_name    = "${var.terraform_bucket_name}"
}
