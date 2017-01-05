#!/bin/bash
#
#  vim:ts=2:sw=2:et
#
source scripts/environment.sh || exit 1

if prompt_assurance "This will DELETE ALL resources, are you sure?" true; then
  time (
    annonce "Delete everything from enviroment: ${YELLOW}${ENVIRONMENT}${NC}"
    scripts/terraform.sh destroy -force=true
  ) || error "unable to delete the entire enviroment"
fi
