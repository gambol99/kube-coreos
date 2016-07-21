#!/bin/bash -x
#
#  vim:ts=2:sw=2:et
#
[ -n "${DEBUG}" ] && set -x

annonce() {
  [ -n "$1" ] && echo "[v] --> $@"
}

failed() {
  echo "[failed] $@" && exit 1
}

error() {
  echo "[error] $@"
}

generate_password() {
  echo $(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c ${1:-24})
}

terraform_get_config() {
  config_value=$(awk -F "=" "/^${1}/ { print \$2; exit;}" $ENVIRONMENT_FILE | sed -e 's/[ ]*//g' -e 's/\"//g')
  echo $config_value
}

[ -n "${ENVIRONMENT_SET}" ] && return

export ENVIRONMENT_FILE=${ENVIRONMENT_FILE:-"env.tfvars"}
export PLATFORM_ENV=$(terraform_get_config "environment")
export CONFIG_AWS_KMS_ID=$(terraform_get_config "kms_master_id")
export CONFIG_DNS_EXTERNAL_ZONE_NAME=$(terraform_get_config "dns_external_zone_name")
export CONFIG_DNS_ZONE_NAME=$(terraform_get_config "dns_zone_name")
export CONFIG_ENVIRONMENT=$(terraform_get_config "environment")
export CONFIG_SECRET_BUCKET_NAME=$(terraform_get_config "secrets_bucket_name")
export CONFIG_TERRAFORM_S3_BUCKET=$(terraform_get_config "terraform_bucket_name")
export CONFIG_AWS_ACCOUNT=$(terraform_get_config "aws_account")
export CONFIG_AWS_ACCESS_KEY=$(terraform_get_config "aws_access_key")
export CONFIG_AWS_SECRET_KEY=$(terraform_get_config "aws_secret_key")
export CONFIG_AWS_REGION=$(terraform_get_config "aws_region")

[ -z "${PLATFORM_ENV}" ] && failed "you need to specify the environment stack, i.e. dev, prod etc"

export SECRETS_DIR="secrets"
export FLEETCTL=${FLEETCTL:-"/usr/bin/fleetctl"}
export FLEETCTL_ENDPOINT=${FLEETCTL_ENDPOINT:-"https://127.0.0.1:2379"}
export KEYPAIR_NAME="${SECRETS_DIR}/locked/${PLATFORM_ENV}"
export KEYPAIR_PUBLIC="${KEYPAIR_NAME}.pem"
export KEYPAIR_PRIVATE="${KEYPAIR_NAME}"
export TERRAFORM=${TERRAFORM:-/opt/terraform/terraform}
export TERRAFORM_VAR_FILES="-var-file=../${ENVIRONMENT_FILE}"
export TERRAFORM_BUCKET=${CONFIG_TERRAFORM_S3_BUCKET:-""}
export TERRAFORM_OPTIONS=${CONFIG_TERRAFORM_OPTIONS:-"-parallelism=20 -backup=-"}
export AWS_ACCESS_KEY_ID=${CONFIG_AWS_ACCESS_KEY}
export AWS_SECRET_ACCESS_KEY=${CONFIG_AWS_SECRET_KEY}
export AWS_DEFAULT_REGION=${CONFIG_AWS_REGION}
export AWS_BUCKET=${CONFIG_SECRET_BUCKET_NAME}
export AWS_S3_BUCKET=${CONFIG_SECRET_BUCKET_NAME}
export AWS_KMS_ID=${CONFIG_AWS_KMS_ID}

# step: ensure the aws credentials are set
[ -z "${AWS_ACCESS_KEY_ID}"     ] && failed "you need to specify the aws access key"
[ -z "${AWS_SECRET_ACCESS_KEY}" ] && failed "you need to specify the aws secret key"
[ -z "${AWS_DEFAULT_REGION}"    ] && failed "you need to specify the aws region"

# step: export the terraform variables
while IFS='=' read NAME VALUE; do
  TF_NAME=$(echo ${NAME/CONFIG_/} | tr 'A-Z' 'a-z')
  TF_VALUE=$(echo $VALUE | sed -e "s/[\"']//g")
  export TF_VAR_${TF_NAME}="${TF_VALUE}"
done < <(set | grep ^CONFIG_)

export COMMON_FILES="ca.pem etcd-key.pem etcd.pem"
export COMPUTE_FILES="kubeconfig_kubelet kubeconfig_proxy"
export LOCKED_FILES="ca-key.pem ca.csr dev dev.pub etcd-csr.json etcd.csr"
export SECURE_FILES="auth-policy.json kubeapi-key.pem kubeapi.csr kubeapi.pem kubeconfig_admin kubeconfig_controller kubeconfig_scheduler tokens.csv"
export ENVIRONMENT_SET=1

mkdir -p ${SECRETS_DIR}
mkdir -p ${SECRETS_DIR}/{secure,compute,common,locked}
