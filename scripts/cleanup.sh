#!/bin/bash
#
#  vim:ts=2:sw=2:et
#
source scripts/environment.sh || exit 1

read -r -p "This will DELETE ALL resources, are you sure? [yes/no] " response
if [[ $response =~ ^[yY][Ee][Ss]$ ]]; then
  if [[ "${ENVIRONMENT}" =~ ^prod.*$ ]]; then
    annonce "${RED}REFUSING${NC} to delete non-plaground enviroment: '${YELLOW}${ENVIRONMENT}${NC}', you will have to manully comment me out in: '$0'"
    exit 1
  fi
  time (
    annonce "Delete everything from enviroment: ${YELLOW}${ENVIRONMENT}${NC}"
    scripts/terraform.sh destroy -force=true
  ) || error "unable to delete the entire enviroment"
fi
