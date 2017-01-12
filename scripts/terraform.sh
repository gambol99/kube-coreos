#!/bin/bash
#
#  vim:ts=2:sw=2:et
#
source scripts/environment.sh || exit 1

PROVIDER_DIR="terraform"
PROVIDER_STATE_DIR="${WORKDIR}/state"
RET=0

# step: check if a remote bucket was provided
[[ -z "${TERRAFORM_BUCKET}" ]] && failed "you have not specified a terraform state bucket in the environment file"

# step: pull in or create the terraform remote state
if [ -n "${TERRAFORM_BUCKET}" ]; then
  if [ ! -f "${PROVIDER_DIR}/.terraform/terraform.tfstate" ]; then
    BUCKET_KEY="${AWS_DEFAULT_REGION}/${ENVIRONMENT}/kube-platform/terraform.tfstate"
    annonce "Setting the remote terraform config, path: s3://${TERRAFORM_BUCKET}/${BUCKET_KEY}"
    (
      cd ${PROVIDER_DIR} && \
      terraform remote config \
        --backend=S3 \
        --backend-config="access_key=${AWS_ACCESS_KEY_ID}" \
        --backend-config="bucket=${TERRAFORM_BUCKET}" \
        --backend-config="encrypt=true" \
        --backend-config="key=${BUCKET_KEY}" \
        --backend-config="region=${AWS_DEFAULT_REGION}" \
        --backend-config="secret_key=${AWS_SECRET_ACCESS_KEY}"
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
      cd ${PROVIDER_DIR} && $TERRAFORM get -update &&
      $TERRAFORM ${COMMAND} ${TERRAFORM_OPTIONS} ${TERRAFORM_VAR_FILES} $@
    ) || { error "unable to complete terraform operation"; RET=1; }
    ;;
  plan)
    shift
    (
      cd ${PROVIDER_DIR} && $TERRAFORM get -update &&
      $TERRAFORM ${COMMAND} ${TERRAFORM_OPTIONS} -module-depth=-1 ${TERRAFORM_VAR_FILES} $@
    ) || { error "unable to complete terraform operation"; RET=1; }
    ;;
  get)
    (
      cd ${PROVIDER_DIR} && $TERRAFORM get
    ) || failed "unable to complete terraform operation"
    ;;
  show|graph|taint|output)
    shift
    (
      cd ${PROVIDER_DIR} && $TERRAFORM get -update >/dev/null &&
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
