#!/bin/bash
#
#  vim:ts=2:sw=2:et
#
export WORKDIR=/platform

[[ -f "${WORKDIR}/scripts/environment.sh" ]] && source "${WORKDIR}/scripts/environment.sh"
[[ -f "/etc/profile.d/bash_completion.sh" ]] && source "/etc/profile.d/bash_completion.sh"

## Aliases
alias vim="vi"
alias ll="ls -l"
alias ..="cd .."

# source in kubectl completion
source <(kubectl completion bash)

# if not master, show the branch
export PS1="[${PLATFORM_ENV}@\W]$ "
if [[ "${GIT_BRANCH}" != "master" ]]; then
  PS1="[${PLATFORM_ENV}@\W] (${YELLOW}${GIT_BRANCH}${NC}) $ "
fi

plan() { run_platform scripts/terraform.sh plan; }
run-plan() { run_platform scripts/run.sh plan; }
run() { run_platform scripts/run.sh; }

# apply if responsible to applying the terraform config
apply() {
  local force="$1"
  if [[ ! "${force}" =~ ^(-f|--force)$ ]]; then
    if ! prompt_assurance "Are you sure you want perform a terraform apply?" false; then
      return
    fi
  fi
  run_platform scripts/terraform.sh apply
}

fetch-secrets()  { run_platform scripts/secrets.sh fetch;  }
upload-secrets() { run_platform scripts/secrets.sh upload; }

show-cert() {
  local filename=$1
  if [[ -f "${filename}" ]]; then
    openssl x509 -in ${filename} -text -noout
  fi
}

run_platform() {
  (cd /platform && eval $@)
}

# aws-terminate is responsible for terminating a specific instance
aws-terminate() { aws ec2 terminate-instances --instance-ids=${1} --output json; }
terminate-bastion() { terminate-layer "bastion";  }
terminate-compute() { terminate-layer "compute"; }
terminate-masters() { terminate-layer "secure";  }

# scale-compute is a helper method for setting the desired capacity of the compute cluser
scale-compute() {
  local capacity="${1}"
  local asg=$(scripts/terrform.sh output play-jest-compute-asg)
  [[ "${capacity}" =~ ^[0-9]*$ ]] || { error "the capacity must be a interger"; return; }
  [[ "${capacity}" =~ ^0.*$    ]] && { error "the capacity must be positive"; return; }
  [[ -z "${asg}" ]] && { error "unable to find the compute asg"; return; }
  if prompt_assurance "Are you sure you wish to scale compute to: ${capacity} nodes" true; then
    if aws autoscaling set-desired-capacity \
      --auto-scaling-group-name ${asg} \
      --desired-capacity ${capacity}; then
      annonce "successfully scaled the compute asg: ${asg} to: ${capacity}"
    else
      error "failed to scale the compute cluster: ${asg}"
    fi
  fi
}

terminate-layer() {
  local layer="$1"
  # step: ensure we can't do this on a non-playground account
  if prompt_assurance "Are you sure you wish to terminate ${1} boxes?" true; then
    aws ec2 describe-instances \
      --filters "Name=instance-state-name,Values=running" "Name=tag:Env,Values=${PLATFORM_ENV}" \
      --query 'Reservations[].Instances[].[ [Tags[?Key==`Name`].Value][0][0],InstanceId,State.Name ]' \
      --output text | awk "/${layer}/ { print \$1,\$2,\$3 }" | while read name id status; do
      if [[ "${status}" == "running" ]]; then
        echo -n "terminating instance: ${name} (${id})"
        if aws-terminate ${id} >/dev/null 2>/dev/null; then
          echo -e "  ${YELLOW}[OK]${NC}"
        else
          echo -e "  ${RED}[FAILED]${NC}"
        fi
      fi
    done
  fi
}

# aws-instances is responsible for display the list of instances in our environment
aws-instances() {
  aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" "Name=tag:Env,Values=${PLATFORM_ENV}" \
    --query 'Reservations[].Instances[].[ [Tags[?Key==`Name`].Value][0][0],PrivateIpAddress,PublicIpAddress,InstanceId,State.Name,Placement.AvailabilityZone ]' \
    --output table
}

# aws-volumes is responsible for display the list of instances in our environment
aws-volumes() {
  aws ec2 describe-volumes \
    --filters "Name=tag:Env,Values=${PLATFORM_ENV}" \
    --query 'Volumes[].[VolumeId,[Tags[?Key==`Name`].Value][0][0],AvailabilityZone,Size,State,State,Iops.Encrypted ]' \
    --output table
}

# aws-elbs is responsible for display the list of elb in our account
aws-elbs() {
  aws elb describe-load-balancers \
    --query 'LoadBalancerDescriptions[].[LoadBalancerName,DNSName]' \
    --output table
}

# prompt_assurance is responsible for interactively prompting user for ensure they meant it
prompt_assurance() {
  local message="$1"
  local play_check="$2"
  [[ -z "${message}" ]] && return 1
  echo -n -e "${message} (yes/no) "; read choice
  # check: unless yes or y return 1
  [[ ! "${choice}" =~ ^(yes|[yY])$ ]] && return 1
  # check: are we double checking
  if [[ "${play_check}" == true && ! "${PLATFORM_ENV}" =~ ^play.*$ ]]; then
    echo -n -e "Are you ABSOLUTELY SURE, given this is a non-playground account? (yes/no) "; read sure
    [[ ! "${sure}" =~ ^(yes|[yY])$ ]] && return 1
  fi
  return 0
}
