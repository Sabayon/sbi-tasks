#!/bin/bash
# Author: Daniele Rondina, geaaru@sabayonlinux.org

set -e

LUET_BIN=${LUET_BIN:-/usr/bin/luet}
LUET_CONFIG=${LUET_CONFIG:-/tmp/luet.yaml}
PKGS4_TASK=${PKGS4_TASK:-1}
TREE_PATH="${TREE_PATH:-../../../../mocaccino/kernel-repo/}"
CONCURRENCY=${CONCURRENCY:-1}
TASK_NAME_PREFIX="${TASK_NAME_PREFIX:-AMD64 mocaccinoos/kernel: }"
LUET_OPTS="${LUET_OPTS:-}"
MCLI_OPTS="${MCLI_OPTS:-}"

export LUET_LOGGING__LEVEL="info"
export LUET_GENERAL__DEBUG="false"

echo "
logging:
  level: info

general:
  debug: false
" > /tmp/luet.yaml

# Retrieve list of packages
n_pkgs=$(${LUET_BIN} --config ${LUET_CONFIG} tree pkglist --tree ${TREE_PATH}/packages ${LUET_OPTS} | wc -l)
pkgs=$(${LUET_BIN} --config ${LUET_CONFIG} tree pkglist --tree ${TREE_PATH}/packages ${LUET_OPTS})


push_task () {
  local n_task=$1
  local list=$2
  local opts=""
  local task_name="${TASK_NAME_PREFIX} $list - ${n_task}/${n_pkgs}"
  mkdir -p /tmp/luet-repo

  mottainai-cli task compile build-pkgs.tmpl \
    -s TaskName="$task_name" \
    -s LuetPkgs="$list" \
    -o /tmp/luet-repo/task_${n_task}.yaml

  if [ -z "${SKIP_FIRE}" ] ; then
    mottainai-cli task create --yaml /tmp/luet-repo/task_${n_task}.yaml ${MCLI_OPTS}
  fi
}

task=0
pos=0
task_pkgs=""
for pkg in ${pkgs} ; do

  let pos++ || true
  if [ $pos -eq 1 ] ; then
    task_pkgs="${pkg}"
  else
    task_pkgs="${task_pkgs} ${pkg}"
  fi
  if [ $pos = $PKGS4_TASK ] ; then
    pos=0
    let task++ || true
    push_task "${task}" "${task_pkgs}"
  fi

done

if [ $pos -gt 0 ] ; then
    let task++ || true
    push_task "${task}" "${task_pkgs}"
fi
