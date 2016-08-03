#!/bin/bash
#
#  vim:ts=2:sw=2:et
#

source scripts/environment.sh || exit 1

scripts/terraform.sh apply -target="module.kube.aws_s3_bucket.secrets" || failed "unable to create the buckets" &&
scripts/secrets.sh fetch    || failed "unable to fetch secrets from the bucket" &&
scripts/keypairs.sh         || failed "unable to generate the keypairs" &&
scripts/assets.sh           || failed "unable to generate the assets" &&
scripts/secrets.sh upload   || failed "unable to upload the secrets from the bucket" &&
scripts/terraform.sh apply  || failed "unable to complete a terraform plan" &&
#scripts/rollout.sh          || failed "unable to perform a rollout"
echo
