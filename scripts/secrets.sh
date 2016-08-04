#!/bin/bash
#
#  vim:ts=2:sw=2:et
#
source scripts/environment.sh || exit 1

upload_secrets() {
  annonce "Uploading the secrets to the s3 bucket: ${CONFIG_SECRET_BUCKET_NAME}"
  (
    cd secrets/
    for _file in */**; do
      # step: we dont need to push the manifests
      [[ "${_file}" =~ ^manifests.*$ ]] && continue
      kmsctl put --bucket ${CONFIG_SECRET_BUCKET_NAME} --kms ${CONFIG_AWS_KMS_ID} ${_file}
    done
  )
}

fetch_secrets() {
  annonce "Fetching the secrets to the s3 bucket: ${CONFIG_SECRET_BUCKET_NAME}"
  kmsctl get --bucket ${CONFIG_SECRET_BUCKET_NAME} --flatten=false -d=${SECRETS_DIR} --recursive /
  setup_secrets
}

setup_secrets() {
  mkdir -p ${HOME}/.kube
  if [[ ! -L "${HOME}/.kube/config" ]]; then
    ln -sf ${PWD}/${SECRETS_DIR}/secure/kubeconfig_admin ${HOME}/.kube/config
  fi
}

case "$1" in
  -f|fetch)   fetch_secrets  ;;
  -u|upload)  upload_secrets ;;
  *)          failed "unknown command, must be either fetch or upload"n
esac
