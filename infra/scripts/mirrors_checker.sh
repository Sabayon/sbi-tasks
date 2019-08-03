#!/bin/bash
# Authors: Sabayon Dev Teams

set -e

MIRROR_NAMESPACE="${MIRROR_NAMESPACE:-/sbi/mirrors-status}"
NAMESPACE_PATH="${NAMESPACE_PATH:-/mirrors}"

create_report_file () {
  # Retrieve list of our mirrors
  local mirrors=`cat /etc/entropy/repositories.conf.d/entropy_sabayon-weekly  | grep ^pkg | awk '{ print $3 }'`
  local mirror=""

  for mirror in $mirrors ; do
    if mirror = "http://pkg.sabayon.org" ; then
      continue
    fi

    mirror="${mirror/\/entropy//}"

    echo $mirror
    # Fetch MIRROR_NAMESPACE from every node and create datasource for web client.
    # TODO
  done

}

main() {

  local nowdate=$(date +"%Y-%m-%d %H:%M:%S" -u)

  # Sync date
  echo "$nowdate" > ${NAMESPACE_PATH}/MIRROR_DATETIME

  # create_report_file

}

main
