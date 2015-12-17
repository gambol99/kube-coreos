#!/bin/bash
#
#  vim:ts=2:sw=2:et
#
source scripts/environment.sh || exit 1

if [[ ! -S ${SSH_AUTH_SOCK} ]] || [[ ! -d /proc/${SSH_AGENT_PID} ]]; then
  eval `ssh-agent -s` && ssh-add ${KEYPAIR_NAME}
fi

if [[ ! -S /var/run/ssh-aws.socket ]]; then
  ssh -o 'StrictHostKeyChecking=no' \
      -o 'ExitOnForwardFailure=yes' \
      -l core \
      -M -S /var/run/ssh-aws.socket \
      -fnNT \
      -L 6443:127.0.0.1:6443 \
      -L 2379:127.0.0.1:2379 $1
fi
