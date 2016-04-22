#!/bin/bash
#
#  vim:ts=2:sw=2:et
#
source scripts/environment.sh || exit 1

export AWS_KMS_ID=${CONFIG_AWS_KMS_ID}

upload_secret() {
  local path="$1"
  local filename="$2"
  annonce "uploading the secret to s3://${CONFIG_SECRET_BUCKET_NAME}/${path}/${filename}"
  s3secrets s3 put -b ${CONFIG_SECRET_BUCKET_NAME} -p ${path}/ ${SECRETS_DIR}/${filename}  >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    failed "failed to push the secret to s3://${CONFIG_SECRET_BUCKET_NAME}/${path}/${filename}"
  fi
}

upload_secrets() {
  annonce "Uploading the secrets to the s3 bucket: ${CONFIG_SECRET_BUCKET_NAME}"
  for filename in ${SECURE_FILES}; do
    upload_secret "secure" "${filename}"
  done
  for filename in ${LOCKED_FILES}; do
    upload_secret "locked" "${filename}"
  done
  for filename in ${COMPUTE_FILES}; do
    upload_secret "compute" "${filename}"
  done
  for filename in ${COMMON_FILES}; do
    upload_secret "common" "${filename}"
  done
}

fetch_secrets() {
  annonce "Fetching the secrets to the s3 bucket: ${CONFIG_SECRET_BUCKET_NAME}"
  for _path in secure compute locked common; do
    s3secrets s3 get -b ${CONFIG_SECRET_BUCKET_NAME} -R -d ${SECRETS_DIR} ${_path} >/dev/null 2>&1 || true
  done
  s3secrets s3 get -b ${CONFIG_SECRET_BUCKET_NAME} -R -N -d ${SECRETS_DIR} manifests/ >/dev/null 2>&1 || true
}

case "$1" in
  -f|fetch)   fetch_secrets  ;;
  -u|upload)  upload_secrets ;;
  *)          failed "unknown command, must be either fetch or upload"
esac
