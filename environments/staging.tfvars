#
# Development Environment
#
aws_profile              = "hod-playground"
aws_region               = "eu-west-1"
environment              = "staging"
kms_master_id            = "cce72fca-5dd8-4563-92ac-d1c5f603170d"
kubeapi_dns              = "kube-staging"
private_zone_name        = "eu.datomic.co.uk"
public_zone_name         = "eu.datomic.co.uk"
secrets_bucket_name      = "staging-dsp-io-secrets-eu-west-1"
vpc_cidr                 = "10.80.0.0/16"
compute_flavor           = "t2.large"
secure_flavor            = "t2.medium"

kubeapi_access_list = [
  "86.128.189.65/32"
]
ssh_access_list = [
  "86.128.189.65/32"
]

nat_subnets = {
  "az0_cidr"  = "10.80.0.0/24"
  "az1_cidr"  = "10.80.1.0/24"
  "az2_cidr"  = "10.80.2.0/24"
  "az0_zone"  = "eu-west-1a"
  "az1_zone"  = "eu-west-1b"
  "az2_zone"  = "eu-west-1c"
}
compute_subnets = {
  "az0_cidr"  = "10.80.20.0/24"
  "az1_cidr"  = "10.80.21.0/24"
  "az2_cidr"  = "10.80.22.0/24"
  "az0_zone"  = "eu-west-1a"
  "az1_zone"  = "eu-west-1b"
  "az2_zone"  = "eu-west-1c"
}
secure_subnets = {
  "az0_cidr"  = "10.80.10.0/24"
  "az1_cidr"  = "10.80.11.0/24"
  "az2_cidr"  = "10.80.12.0/24"
  "az0_zone"  = "eu-west-1a"
  "az1_zone"  = "eu-west-1b"
  "az2_zone"  = "eu-west-1c"
}
elb_subnets = {
  "az0_cidr"  = "10.80.100.0/24"
  "az1_cidr"  = "10.80.101.0/24"
  "az2_cidr"  = "10.80.102.0/24"
  "az0_zone"  = "eu-west-1a"
  "az1_zone"  = "eu-west-1b"
  "az2_zone"  = "eu-west-1c"
}
mgmt_subnets = {
  "az0_cidr"  = "10.80.110.0/24"
  "az1_cidr"  = "10.80.111.0/24"
  "az2_cidr"  = "10.80.112.0/24"
  "az0_zone"  = "eu-west-1a"
  "az1_zone"  = "eu-west-1b"
  "az2_zone"  = "eu-west-1c"
}

secure_nodes = {
  "node0" = "10.80.10.100"
  "node1" = "10.80.10.101"
  "node2" = "10.80.11.100"
  "node3" = "10.80.11.101"
  "node4" = "10.80.12.100"
}

secure_nodes_info = {
  "10.80.10.100_subnet" = 0
  "10.80.10.101_subnet" = 0
  "10.80.11.100_subnet" = 1
  "10.80.11.101_subnet" = 1
  "10.80.12.100_subnet" = 2
  "10.80.10.100_zone"   = "eu-west-1a"
  "10.80.10.101_zone"   = "eu-west-1a"
  "10.80.11.100_zone"   = "eu-west-1b"
  "10.80.11.101_zone"   = "eu-west-1b"
  "10.80.12.100_zone"   = "eu-west-1c"
}
