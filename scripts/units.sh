#!/bin/bash
#
#  vim:ts=2:sw=2:et
#
source scripts/environment.sh || exit 1

destroy_unit() {
  if ${FLEETCTL} destroy ${1} >/dev/null 2>&1; then
    annonce "successfully destoryed the ${1}"
  else
    failed "unable to destroy the unit file ${1}"
  fi
}

start_unit() {
  if ${FLEETCTL} start ${1} >/dev/null 2>&1; then
    annonce "successfully destoryed the ${1}"
  else
    failed "unable to started up the unit file ${1}"
  fi
}

deploy() {
  annonce "deploying the fleet units"
  for _unit in units/*/**; do
    unit_name=$(basename ${_unit})
    # step: check the status of the unit
    if ${FLEETCTL} list-units -no-legend=false -full | grep "^${unit_name}.*dead"; then
      annonce "unit: ${_unit} appears to be dead, destorying and restarting the service now"
      destroy_unit ${_unit}
    fi

    annonce "starting the unit service: ${_unit}"
    if ${FLEETCTL} start ${_unit} 2>&1 | grep -q "^WARNING: Unit ${unit_name} in registry differs from local unit file"; then
      annonce "unit: ${unit_name} is out of sync, redeploying the unit now"
      start_unit ${_unit}
    fi
  done
}

destroy() {
  annonce "deleting all the fleet units from the cluster"
  for _unit in units/*/**; do
    annonce "destroying the unit ${_unit}"
    unit_name=$(basename ${_unit})
    ${FLEETCTL} destroy ${_unit} || failed "unable to destroy the unit file ${_unit}"
  done
}

case "$1" in
  destroy)    destory;  ;;
  deploy)     deploy;   ;;
  *)          deploy;   ;;
esac
