
## AWS Platform
module "platform" {
  source                   = "modules/platform"

  aws_region               = "${var.aws_region}"
  compute_subnets          = "${var.compute_subnets}"
  elb_subnets              = "${var.elb_subnets}"
  environment              = "${var.environment}"
  kms_master_id            = "${var.kms_master_id}"
  mgmt_subnets             = "${var.mgmt_subnets}"
  nat_subnets              = "${var.nat_subnets}"
  private_zone_name        = "${var.private_zone_name}"
  public_zone_name         = "${var.public_zone_name}"
  secrets_bucket_name      = "${var.secrets_bucket_name}"
  secure_subnets           = "${var.secure_subnets}"
  ssh_access_list          = "${var.ssh_access_list}"
  vpc_cidr                 = "${var.vpc_cidr}"
}

module "master" {
  source                   = "./modules/kube/master"

  coreos_image             = "${var.coreos_image}"
  coreos_image_owner       = "${var.coreos_image_owner}"
  enable_calico            = "${var.enable_calico}"
  environment              = "${var.environment}"
  etcd_dns                 = "${var.etcd_dns}"
  flannel_cidr             = "${var.flannel_cidr}"
  kms_master_id            = "${var.kms_master_id}"
  kubeapi_internal_dns     = "${var.kubeapi_internal_dns}"
  kubernetes_image         = "${var.kubernetes_image}"
  private_zone_name        = "${var.private_zone_name}"
  public_zone_name         = "${var.public_zone_name}"
  secrets_bucket_name      = "${var.secrets_bucket_name}"
  secure_asg_grace_period  = "${var.secure_asg_grace_period}"
  secure_data_encrypted    = "${var.secure_data_encrypted}"
  secure_data_volume       = "${var.secure_data_volume}"
  secure_docker_volume     = "${var.secure_docker_volume}"
  secure_flavor            = "${var.secure_flavor}"
  secure_nodes             = "${var.secure_nodes}"
  secure_nodes_info        = "${var.secure_nodes_info}"
  secure_root_volume       = "${var.secure_root_volume}"

  aws_region               = "${var.aws_region}"
  compute_sg               = "${module.platform.compute_sg}"
  compute_subnets          = "${module.platform.compute_subnets}"
  elb_sg                   = "${module.platform.elb_sg}"
  elb_subnets              = "${module.platform.elb_subnets}"
  key_name                 = "${module.platform.key_name}"
  mgmt_sg                  = "${module.platform.mgmt_sg}"
  mgmt_subnets             = "${module.platform.mgmt_subnets}"
  nat_sg                   = "${module.platform.nat_sg}"
  nat_subnets              = "${module.platform.nat_subnets}"
  private_zone             = "${module.platform.private_zone}"
  public_zone              = "${module.platform.public_zone}"
  secure_sg                = "${module.platform.secure_sg}"
  secure_subnets           = "${module.platform.secure_subnets}"
  vpc_id                   = "${module.platform.vpc_id}"
}

module "api" {
  source                   = "./modules/kube/api"

  environment              = "${var.environment}"
  kubeapi_access_list      = "${var.kubeapi_access_list}"
  kubeapi_dns              = "${var.kubeapi_dns}"
  kubeapi_external_elb     = "${var.kubeapi_external_elb}"
  kubeapi_internal_dns     = "${var.kubeapi_internal_dns}"
  private_zone_name        = "${var.private_zone_name}"
  public_zone_name         = "${var.public_zone_name}"
  secure_asg               = "${module.master.secure_asg}"

  aws_region               = "${var.aws_region}"
  compute_sg               = "${module.platform.compute_sg}"
  compute_subnets          = "${module.platform.compute_subnets}"
  elb_sg                   = "${module.platform.elb_sg}"
  elb_subnets              = "${module.platform.elb_subnets}"
  mgmt_sg                  = "${module.platform.mgmt_sg}"
  mgmt_subnets             = "${module.platform.mgmt_subnets}"
  private_zone             = "${module.platform.private_zone}"
  public_zone              = "${module.platform.public_zone}"
  secure_sg                = "${module.platform.secure_sg}"
  secure_subnets           = "${module.platform.secure_subnets}"
  vpc_id                   = "${module.platform.vpc_id}"
}

module "compute" {
  source                     = "./modules/kube/compute"

  compute_asg_grace_period   = "${var.compute_asg_grace_period}"
  compute_asg_max            = "${var.compute_asg_max}"
  compute_asg_min            = "${var.compute_asg_min}"
  compute_docker_volume      = "${var.compute_docker_volume}"
  compute_docker_volume_type = "${var.compute_docker_volume_type}"
  compute_flavor             = "${var.compute_flavor}"
  compute_root_volume        = "${var.compute_root_volume}"
  coreos_image               = "${var.coreos_image}"
  enable_calico              = "${var.enable_calico}"
  environment                = "${var.environment}"
  etcd_memberlist            = "${module.master.etcd_members_url}"
  flannel_memberlist         = "${module.master.flannel_members_url}"
  kms_master_id              = "${var.kms_master_id}"
  kubeapi_dns                = "${module.api.kubeapi_internal_dns}"
  kubernetes_image           = "${var.kubernetes_image}"
  private_zone_name          = "${var.private_zone_name}"
  public_zone_name           = "${var.public_zone_name}"
  secrets_bucket_name        = "${var.secrets_bucket_name}"

  aws_region                 = "${var.aws_region}"
  compute_sg                 = "${module.platform.compute_sg}"
  compute_subnets            = "${module.platform.compute_subnets}"
  elb_sg                     = "${module.platform.elb_sg}"
  elb_subnets                = "${module.platform.elb_subnets}"
  key_name                   = "${module.platform.key_name}"
  mgmt_sg                    = "${module.platform.mgmt_sg}"
  mgmt_subnets               = "${module.platform.mgmt_subnets}"
  nat_sg                     = "${module.platform.nat_sg}"
  nat_subnets                = "${module.platform.nat_subnets}"
  private_zone               = "${module.platform.private_zone}"
  public_zone                = "${module.platform.public_zone}"
  secure_sg                  = "${module.platform.secure_sg}"
  secure_subnets             = "${module.platform.secure_subnets}"
  vpc_id                     = "${module.platform.vpc_id}"
}

module "bastion" {
  source                     = "./modules/bastion"

  bastion_image              = "${var.coreos_image}"
  bastion_image_owner        = "${var.coreos_image_owner}"
  environment                = "${var.environment}"
  kms_master_id              = "${var.kms_master_id}"
  kubernetes_image           = "${var.kubernetes_image}"
  private_zone_name          = "${var.private_zone_name}"
  public_zone_name           = "${var.public_zone_name}"
  secrets_bucket_name        = "${var.secrets_bucket_name}"

  aws_region                 = "${var.aws_region}"
  bastion_subnets            = "${module.platform.mgmt_subnets}"
  bastion_sg                 = "${module.platform.mgmt_sg}"
  key_name                   = "${module.platform.key_name}"
  vpc_id                     = "${module.platform.vpc_id}"
}

#
## Outputs
#
output "kubeapi_public"        { value = "${module.api.kubeapi_dns}" }
output "kubeapi_public_elb"    { value = "${module.api.kubeapi_dns_aws}"}
output "compute_asg"           { value = "${module.compute.compute_asg_name}"}
output "public_name_services"  { value = [ "${module.platform.public_nameservers}" ] }
