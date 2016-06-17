#!/bin/bash
#
#  vim:ts=2:sw=2:et
#
source scripts/environment.sh || exit 1

FLEETCTL="/usr/bin/fleetctl --endpoint=https://127.0.0.1:2379"

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

list() {
  ${FLEETCTL} list-units -no-legend=false -full 2>/dev/null
}

machines() {
  ${FLEETCTL} list-machines -no-legend=false -full  2>/dev/null
}

deploy() {
  annonce "deploying the fleet units"
  for _unit in units/*; do
    unit_name=$(basename ${_unit})
    # step: check the status of the unit
    if ${FLEETCTL} list-units -no-legend=false -full 2>/dev/null | grep "^${unit_name}.*dead"; then
      annonce "unit: ${_unit} appears to be dead, destorying and restarting the service now"
      destroy_unit ${_unit}
    fi

    annonce "checking the unit service is running: ${_unit}"
    if ${FLEETCTL} start ${_unit} 2>&1 | grep -q "^WARNING: Unit ${unit_name} in registry differs from local unit file"; then
      annonce "unit: ${unit_name} is out of sync, redeploying the unit now"
      destroy_unit ${_unit} && start_unit ${_unit}
    fi
  done
}

destroy() {
  annonce "deleting all the fleet units from the cluster"
  for _unit in units/*; do
    annonce "destroying the unit ${_unit}"
    unit_name=$(basename ${_unit})
    ${FLEETCTL} destroy ${_unit} 2>/dev/null || failed "unable to destroy the unit file ${_unit}"
  done
}

case "$1" in
  destroy)    destroy;  ;;
  deploy)     deploy;   ;;
  list)       list;     ;;
  machines)   machines; ;;
  *)          deploy;   ;;
esac
