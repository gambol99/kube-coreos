#!/bin/bash
#
#  vim:ts=2:sw=2:et
#
source scripts/environment.sh || exit 1

PROVIDER_DIR="terraform"
PROVIDER_STATE_DIR="${WORKDIR}/state"
RET=0

# step: check if a remote bucket was provided
if [ -n "${TERRAFORM_BUCKET}" ]; then
  if [ ! -f "${PROVIDER_DIR}/.terraform/terraform.tfstate" ]; then
    annonce "Setting the remote terraform config, path: s3://${TERRAFORM_BUCKET}/${AWS_DEFAULT_REGION}/${ENVIRONMENT}/hoddat_users/terraform.tfstate"
    (
      cd ${PROVIDER_DIR} && \
      terraform remote config \
        --backend=S3 \
        --backend-config="profile=${CONFIG_AWS_PROFILE}" \
        --backend-config="shared_credentials_file=/root/.aws/credentials" \
        --backend-config="region=${CONFIG_AWS_REGION}" \
        --backend-config="bucket=${TERRAFORM_BUCKET}" \
        --backend-config="key=${AWS_DEFAULT_REGION}/${ENVIRONMENT}/kube-platform/terraform.tfstate" \
        --backend-config="encrypt=true"
    ) || {
      echo "failed to initialize or pull the terraform remote configuration";
      exit 1;
    }
  fi
  (
    annonce "Retrieving the terraform remote state"
    cd terraform &&
    terraform remote pull
  ) || failed "unable to pull the terraform remote state"
fi

COMMAND=$1
case "${COMMAND}" in
  apply|destroy)
    shift
    (
      cd ${PROVIDER_DIR} && $TERRAFORM get &&
      $TERRAFORM ${COMMAND} ${TERRAFORM_OPTIONS} ${TERRAFORM_VAR_FILES} $@
    ) || { error "unable to complete terraform operation"; RET=1; }
    ;;
  plan)
    shift
    (
      cd ${PROVIDER_DIR} && $TERRAFORM get -update=true &&
      $TERRAFORM ${COMMAND} ${TERRAFORM_OPTIONS} -module-depth=-1 ${TERRAFORM_VAR_FILES} $@
    ) || { error "unable to complete terraform operation"; RET=1; }
    ;;
  get)
    (
      cd ${PROVIDER_DIR} && $TERRAFORM get -update=true
    ) || failed "unable to complete terraform operation"
    ;;
  show|graph|taint|output)
    shift
    (
      cd ${PROVIDER_DIR} && $TERRAFORM get >/dev/null &&
      $TERRAFORM ${COMMAND} $@
    ) || { error "unable to complete terraform operation"; RET=1; }
    ;;
  *)
    failed "you have not specified a command to run"
    exit 1
    ;;
esac

if [[ -n "${TERRAFORM_BUCKET}" ]]; then
  if [[ "${COMMAND}" =~ ^(apply||destroy||import)$ ]]; then
    annonce "Pushing the terraform state to remote site"
    (
      cd ${PROVIDER_DIR}
      $TERRAFORM remote push
    ) || { error "unable to push the terraform state remotely"; RET=1; }
  fi
fi

exit $RET
