#!/bin/bash
# Author: Daniele Rondina, geaaru@sabayonlinux.org
# Description: Clean old tasks from Mottainai Server

set -e

DEBUG=${DEBUG:-0}
# Define retention period in days. Default 120 days
RETENTION_PERIOD=${RETENTION_PERIOD:-120}

main () {

  local l=0
  local removed=0
  local  nowdate=$(date +"%Y-%m-%d")
  local taskid=""
  local tdate=""
  local days=""

  if [ -z "${MOTTAINAI_CLI_PROFILE}" ] ; then
    echo "No mottainai profile defined!!"
    exit 1
  fi

  echo "Searching for old task to remove..."
  local tasks_list=$(mottainai-cli task list | grep -w "success\|failed\|error" --color=none | awk -F "|" '{str = sprintf("%s_%s", $8, $2)} { print str }' | awk '{str = sprintf("%s_%s", $1, $6)} { print str }')
  for i in ${tasks_list} ; do
    taskid=""
    tdate=""
    days=""

    let l++ || true
    if [ $l -lt 3 ] ; then
      # Skip header
      continue
    fi
    taskid=$(echo $i | sed -e 's:.*_::g')
    tdate=$(echo $i | sed -e 's:_.*::g')
    days=$(python -c "from datetime import datetime; print ((datetime.strptime('$nowdate', '%Y-%m-%d')-datetime.strptime('$tdate', '%Y-%m-%d')).days)")

    if [ "$DEBUG" = 1 ] ; then
      echo "Check task ${taskid} with date ${tdate}: days $days"
    fi

    if [ $days -gt ${RETENTION_PERIOD} ] ; then
      echo "Removing task $taskid ($tdate - $days)"
      mottainai-cli task remove $taskid
      let removed++ || true
    fi
  done

  echo "All done. Removed tasks: $removed."

  exit 0
}

main
