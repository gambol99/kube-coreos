#!/bin/bash
#
#  vim:ts=2:sw=2:et
#
source scripts/environment.sh || exit 1

## check the PLATFORM_ENV and ENVIRONMENT
if [[ ! "${PLATFORM_ENV}" == "${ENVIRONMENT}" ]]; then
  failed "the PLATFORM_ENV: ${PLATFORM_ENV} and ENVIRONMENT: ${ENVIRONMENT} are not the same"
fi

## add in the default command
CMD=${1:-"apply"}

scripts/terraform.sh apply -target="module.platform.aws_s3_bucket.secrets" || failed "unable to create the buckets" &&
scripts/secrets.sh fetch    || failed "unable to fetch secrets from the bucket" &&
scripts/keypairs.sh         || failed "unable to generate the keypairs" &&
scripts/assets.sh           || failed "unable to generate the assets" &&
scripts/secrets.sh upload   || failed "unable to upload the secrets from the bucket" &&
scripts/terraform.sh ${CMD} || failed "unable to complete a terraform plan" &&
echo
