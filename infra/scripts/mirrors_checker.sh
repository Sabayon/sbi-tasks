#!/bin/bash
# Authors: Sabayon Dev Teams

set -e

MIRROR_NAMESPACE="${MIRROR_NAMESPACE:-/sbi/mirrors-status}"
NAMESPACE_PATH="${NAMESPACE_PATH:-/mirrors}"
STATUS_FILE="${STATUS_FILE:-${NAMESPACE_PATH}/mirrors-status.json}"
ORIGIN_NODE="${ORIGIN_NODE:-https://dispatcher.sabayon.org/sbi/namespace}"
REPO_FILE="${REPO_FILE:-/etc/entropy/repositories.conf.d/entropy_sabayonlinux.org}"

log () {
  echo "========================================================="
  echo "$@"
  echo "========================================================="
}

create_report_file () {
  # Retrieve list of our mirrors
  local mirrors=`cat ${REPO_FILE} | grep ^pkg | awk '{ print $3 }'`
  local mirror=""
  local mirror_status=""
  local mirror_ts=""
  local origin_ts=""
  local i=0
  declare -g -A measures
  measures=()

  # Retrieve origin date
  wget -T 10 -t 5 -O /tmp/mirror-origin ${ORIGIN_NODE}/mirrors-status/MIRROR_DATETIME
  origin_ts=$(cat /tmp/mirror-origin)
  log "Origin $ORIGIN_NODE with timestamp $origin_ts"


  echo "Check Secondary Level Node"
  mirror="http://mirror.de.sabayon.org/"
  # Fetch MIRROR_NAMESPACE from every node and create datasource for web client.
  rm -f /tmp/mirror-timestamp || true
  local mres=0
  wget -T 10 -t 5 -O /tmp/mirror-timestamp ${mirror}sbi/mirrors-status/MIRROR_DATETIME || {
    log "ERROR: Mirror Out of sync."
    mirror_ts="OUTSYNC"
    mres=1
  }

  if [ "$mres" = 0 ] ; then
    mirror_ts=$(cat /tmp/mirror-timestamp)
    log "Mirror $mirror with timestamp $mirror_ts"
  fi

  measures[$i]="{ \"mirror\": \"$mirror\", \"status\": \"$mirror_ts\" }"
  let i++ || true

  echo "MIRRORS: $mirrors"
  for mirror in $mirrors ; do
    if [ "$mirror" = "http://pkg.sabayon.org" ] ; then
      echo "skip $mirror"
      continue
    fi

    if [ "$mirror" = "http://dl.sabayon.org" ] ; then
      # This is skipped because redirect over mirrors
      echo "skip $mirror"
      continue
    fi

    mirror_status="OUTSYNC"
    mirror="${mirror/\/entropy//}"

    log "Elaborate Mirror: $mirror"

    # Fetch MIRROR_NAMESPACE from every node and create datasource for web client.
    rm -f /tmp/mirror-timestamp || true
    wget -T 10 -t 5 -O /tmp/mirror-timestamp ${mirror}sbi/mirrors-status/MIRROR_DATETIME || {
      log "ERROR: Mirror Out of sync."
      measures[$i]="{ \"mirror\": \"$mirror\", \"status\": \"$mirror_status\" }"
      let i++ || true
      continue
    }

    mirror_ts=$(cat /tmp/mirror-timestamp)
    log "Mirror $mirror with timestamp $mirror_ts"

    measures[$i]="{ \"mirror\": \"$mirror\", \"status\": \"$mirror_ts\" }"
    let i++ || true
  done


  echo "{ \"origin\": \"${origin_ts}\", \"mirrors\": [ " > ${STATUS_FILE}
  local n_measures=${#measures[@]}
  for ((i=0;i<${n_measures};i++)) ; do
    if [ $i -lt $((n_measures-1)) ] ; then
      echo "${measures[${i}]}," >> ${STATUS_FILE}
    else
      echo "${measures[${i}]}" >> ${STATUS_FILE}
    fi

  done
  echo "] }" >> ${STATUS_FILE}

}

main() {

  local nowdate=$(date +"%Y-%m-%d %H:%M:%S" -u)

  # Sync date
  echo "$nowdate" > ${NAMESPACE_PATH}/MIRROR_DATETIME

  log "Register mirror date: $nowdate"

  create_report_file

}

main
