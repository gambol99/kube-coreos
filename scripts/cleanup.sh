#!/bin/bash
#
#  vim:ts=2:sw=2:et
#
source scripts/environment.sh || exit 1

read -r -p "This will DELETE ALL resource, are you sure? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  (
    annonce "Deleting the autoscaling groups"
    scripts/terraform.sh destroy -force=true -target="module.kube.aws_launch_configuration.secure"  || failed "unable to delete secure autoscaling group"
    scripts/terraform.sh destroy -force=true -target="module.kube.aws_launch_configuration.compute" || failed "unable to delete compute autoscaling group"
    scripts/terraform.sh destroy -force=true -target="module.kube.template_file.compute_user_data"  || failed "unable to delete compute user data"
    annonce "Delete everything else"
    scripts/terraform.sh destroy -force=true || failed "unable to delete the entire stack"
    rm -rf terraform/.terraform

    annonce "Deleting all the secrets"
    rm -rf ${SECRETS_DIR}/
  )
fi