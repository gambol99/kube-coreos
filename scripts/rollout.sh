#!/bin/bash
#
#  vim:ts=2:sw=2:et
#
source scripts/environment.sh || exit 1

annonce "Searching for ASG rollout"
for filename in *.rollout; do
  asg="${filename##*.}"
  annonce "Performing a rollout of ASG ${asg}"
  if ! echo "scripts/ha-release -a ${asg}"; then
    failed "unable to rollout the changes for the asg: ${asg}"
  else
    echo "rm -f ${filename}"
  fi
done
