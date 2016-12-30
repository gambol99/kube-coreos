#!/bin/bash
#
#  vim:ts=2:sw=2:et
#
export WORKDIR=/platform

source ${WORKDIR}/scripts/environment.sh

export PS1="[${PLATFORM_ENV}@\W]$ "

## Aliases
alias vim="vi"
alias ll="ls -l"
alias ..="cd .."

run() {
  run_platform scripts/run.sh
}

run-plan() {
  run_platform scripts/run.sh plan
}

plan() {
  run_platform scripts/terraform.sh plan
}

apply() {
  local force="$1"
  if [[ ! "${force}" == "-f" ]]; then
    echo -n "Are you sure you want perform a terraform apply? (y/n) "
    read choice
    [[ ! "${choice}" =~ ^[yY]$ ]] && return
  fi
  run_platform scripts/terraform.sh apply
}

fetch_secrets() {
  run_platform scripts/secrets.sh fetch
}

upload_secrets() {
  run_platform scripts/secrets.sh upload
}

instances() {
  source scripts/environment.sh
  aws-instances
}

show-cert() {
  local filename=$1
  if [[ -f "${filename}" ]]; then
    openssl x509 -in ${filename} -text -noout
  fi
}

run_platform() {
  (cd /platform && eval $@)
}

aws-terminate() {
  aws ec2 terminate-instances --instance-ids=${1} --output json
}

terminate-compute() {
  terminate_layer "compute"
}

terminate-masters() {
  terminate-layer "secure"
}

terminate_layer() {
  local layer="$1"
  echo -n "Are you sure you wish to terminate compute boxes? (y/n) "
  read choice
  if [[ "${choice}" =~ ^[Yy]$ ]]; then
    aws ec2 describe-instances \
      --filter "Name=instance-state-name,Values=running" \
      --query 'Reservations[].Instances[].[ [Tags[?Key==`Name`].Value][0][0],InstanceId ]' \
      --output text | awk "/${layer}/ { print \$2 }" | while read compute; do
      echo -n "Terminating the compute box: ${compute}"
      if aws-terminate ${compute} >/dev/null 2>/dev/null; then
        printf "%20s" "${YELLOW}[OK]${NC}"
      else
        printf "%20s" "${RED}[OK]${NC}"
      fi
    done
  fi
}

aws-instances() {
  aws ec2 describe-instances \
    --filter "Name=instance-state-name,Values=running" \
    --query 'Reservations[].Instances[].[ [Tags[?Key==`Name`].Value][0][0],PrivateIpAddress,PublicIpAddress,InstanceId,State.Name,Placement.AvailabilityZone ]' \
    --output table
}

aws-volumes() {
  aws ec2 describe-volumes \
    --query 'Volumes[].[VolumeId,[Tags[?Key==`Name`].Value][0][0],AvailabilityZone,Size,State,State,Iops.Encrypted ]' \
    --output table
}

aws-elbs() {
  aws elb describe-load-balancers \
    --query 'LoadBalancerDescriptions[].[LoadBalancerName,DNSName]' \
    --output table
}
