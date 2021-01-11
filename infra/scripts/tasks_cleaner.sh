#!/bin/bash
# Author: Daniele Rondina, geaaru@sabayonlinux.org
# Description: Clean old tasks and pipeline from Mottainai Server

set -e

DEBUG=${DEBUG:-0}
# Define retention period in days. Default 120 days
RETENTION_PERIOD=${RETENTION_PERIOD:-120}

clean_pipelines () {
  # NOTE: tasks of pipeline are removed directly
  local l=0
  local pipelineid=""
  local pdate=""
  local days=""
  local nowdate=$(date +"%Y-%m-%d")
  local removed=0

  echo "Searching for old pipeline to remove..."
  local pipeline_list=$(mottainai-cli pipeline list | awk -F "|" '{str = sprintf("%s_%s", $4, $2)} { print str }' | awk '{str = sprintf("%s_%s", $1, $6)} { print str }')

  for i in ${pipeline_list} ; do
    pipelineid=""
    pdate=""
    days=""

    let l++ || true
    if [ $l -lt 3 ] ; then
      # Skip header
      continue
    fi

    pipelineid=$(echo $i | sed -e 's:.*_::g')

    if [ "$pipelineid" = "" ] ; then
       # handle row with description text of the previous row"
       continue
    fi
    pdate=$(echo $i | sed -e 's:_.*::g')
    days=$(python -c "from datetime import datetime; print ((datetime.strptime('$nowdate', '%Y-%m-%d')-datetime.strptime('$pdate', '%Y-%m-%d')).days)")

    if [ "$DEBUG" = 1 ] ; then
      echo "Check pipeline ${pipelineid} with date ${pdate}: days $days"
    fi

    if [ $days -gt ${RETENTION_PERIOD} ] ; then
      echo "Removing pipeline $pipelineid ($tdate - $days)"
      mottainai-cli pipeline remove $pipelineid
      let removed++ || true
    fi

  done

  echo "Removed pipeline: $removed."
}

clean_tasks () {
  local l=0
  local removed=0
  local nowdate=$(date +"%Y-%m-%d")
  local taskid=""
  local tdate=""
  local days=""

  echo "Searching for old task to remove..."
  local tasks_list=$(mottainai-cli task list -j | jq .[] | jq '.ID + "-" + .created_time' -r)
  for i in ${tasks_list} ; do
    taskid=""
    tdate=""
    days=""

    let l++ || true
    if [ $l -lt 3 ] ; then
      # Skip header
      continue
    fi
    taskid=$(echo $i | cut -d'-' -f 1)
    tdate=$(echo $i | cut -d'-' -f 2)
    tdate=${tdate:0:8}
    if [ "$tdate" == "" ] ; then
      # Something is wrong. Probably is a garbage task old. I will drop it.
      echo "Removing task $taskid is weird status."
      mottainai-cli task remove $taskid
      let removed++ || true
    else
      days=$(python -c "from datetime import datetime; print ((datetime.strptime('$nowdate', '%Y-%m-%d')-datetime.strptime('$tdate', '%Y%m%d')).days)")

      if [ "$DEBUG" = 1 ] ; then
        echo "Check task ${taskid} with date ${tdate}: days $days"
      fi

      if [ $days -gt ${RETENTION_PERIOD} ] ; then
        echo "Removing task $taskid ($tdate - $days)"
        mottainai-cli task remove $taskid
        let removed++ || true
      fi

    fi

  done

  echo "Removed tasks: $removed."
}

main () {

  if [ -z "${MOTTAINAI_CLI_PROFILE}" ] ; then
    echo "No mottainai profile defined!!"
    exit 1
  fi

  clean_tasks

  clean_pipelines

  exit 0
}

main
