#!/bin/bash
# Author: Daniele Rondina, geaaru@sabayonlinux.org
# Description: Remove build_.log from a list of namespace.
#              Needed where append mode is used.

NAMESPACES_LIST="${NAMESPACES_LIST:-}"
REMOVED_FILES=0

# TODO: Add support for remove only logs of the tasks not available.

clean_namespace () {
  local n=$1
  local f=""

  local files="$(mottainai-cli namespace show $n 2>&1 | grep '/build' --color=none | awk '{ print $4 }' | grep '^/build_[0-9]*.log$' --color=none)"
  for f in $files ; do
    echo "[${n}] Removing $f..."
    mottainai-cli namespace remove "${n}" $f
    let REMOVED_FILES++
  done
}

main () {
  local namespace=""

  if [ -z "${NAMESPACES_LIST}" ] ; then
    echo "No namespaces defined!"
    return 1
  fi

  if [ -z "${MOTTAINAI_CLI_PROFILE}" ] ; then
    echo "No mottainai profile defined!!"
    exit 1
  fi

  for namespace in ${NAMESPACES_LIST} ; do
    clean_namespace "$namespace"
  done

  echo "All done. Removed ${REMOVED_FILES} build files."

  exit 0
}

main
exit $?
