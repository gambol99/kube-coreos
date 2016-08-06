#!/bin/bash
#
#  vim:ts=2:sw=2:et
#
source scripts/environment.sh || exit 1

command="$1"

if [[ -n "${TERRAFORM_BUCKET}" ]]; then
  if [[ ! -f "terraform/.terraform/terraform.tfstate" ]]; then
    annonce "Setting the remote terraform config"
    (
      cd terraform
      terraform remote config --backend=S3 \
        --backend-config="bucket=${TERRAFORM_BUCKET}" \
        --backend-config="key=${AWS_DEFAULT_REGION}/${PLATFORM_ENV}/terraform.tfstate" \
        --backend-config="encrypt=true" \
        --backend-config="shared_credentials_file=${AWS_SHARED_CREDENTIALS_FILE}" \
        --backend-config="profile=${AWS_DEFAULT_PROFILE}" \
      terraform remote pull
    ) || failed "failed to initialize or pull the terraform remote configuration"
  else
    (
      annonce "Retrieving the terraform remote state"
      cd terraform
      terraform remote pull
    ) || failed "unable to pull the terraform remote state"
  fi
fi

case "$1" in
  apply|destroy)
    shift
    (
      cd terraform && $TERRAFORM get >/dev/null &&
      $TERRAFORM ${command} ${TERRAFORM_OPTIONS} ${TERRAFORM_VAR_FILES} $@
    ) || error "unable to perform terraform operation"
    ;;
  plan)
    shift
    (
      cd terraform && $TERRAFORM get >/dev/null &&
      $TERRAFORM ${command} ${TERRAFORM_OPTIONS} -module-depth=-1 ${TERRAFORM_VAR_FILES} $@
    ) || failed "unable to perform terraform operation"
    ;;

  show|graph|taint|output)
    shift
    (
      cd terraform && $TERRAFORM get >/dev/null &&
      $TERRAFORM ${command} $@
    ) || failed "unable to perform terraform operation"
    ;;
  *)
    (
      cd terraform && $TERRAFORM get > /dev/null &&
      $TERRAFORM $@
    ) || failed "unable to perform terraform operation"
    ;;
esac

if [[ -n "${TERRAFORM_BUCKET}" ]]; then
  annonce "Pushing the terraform state to remote site"
  (
    cd terraform
    $TERRAFORM remote push
  ) || failed "unable to push the terraform state remotely"
fi
