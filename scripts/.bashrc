#!/bin/bash

source /kube-coreos/scripts/environment.sh

export PS1="[kubernetes@\W]$ "

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
