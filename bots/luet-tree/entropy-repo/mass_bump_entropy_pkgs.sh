#!/bin/bash
# Author: Daniele Rondina, geaaru@sabayonlinux.org

set -e

LUET_BIN=${LUET_BIN:-/usr/bin/luet}
LUET_CONFIG=${LUET_CONFIG:-/tmp/luet.yaml}
PKGS4_TASK=${PKGS4_TASK:-20}
TREE_REPO="${TREE_REPO:-sabayonlinux.org}"
TREE_PATH="${TREE_PATH:-../../../../luet-entropy-repo/tree/}"
CONCURRENCY=${CONCURRENCY:-1}
BUILD_ARGS_NODEPS="${BUILD_ARGS_NODEPS:-1}"

# Temporary disable acct-group/acct-user for entities tool integration
#EXCLUDES="${EXCLUDES:-}"
EXCLUDES="${EXCLUDES:---exclude acct-group --exclude acct-user}"

export LUET_LOGGING__LEVEL="info"
export LUET_GENERAL__DEBUG="false"

echo "
logging:
  level: info

general:
  debug: false
" > /tmp/luet.yaml

# Retrieve list of packages
pkgs=$(${LUET_BIN} --config ${LUET_CONFIG} tree pkglist --tree ${TREE_PATH}${TREE_REPO} ${EXCLUDES} -v)

task_name="Bump luet pkgs $(date -u  +'%Y-%m-%d %H:%M:%S'):"

push_task () {
  local n_task=$1
  local list=$2
  local opts=""

  mkdir -p /tmp/luet-entropy

  if [ "${BUILD_ARGS_NODEPS}" = 1 ] ; then
    opts="-s BuildArgsNoDeps=${BUILD_ARGS_NODEPS}"
  fi

  mottainai-cli task compile build_repo_pkgs.tmpl \
    -s TaskName="$task_name $n_task" \
    -s LuetPkgs="$list" \
    -s Concurrency=${CONCURRENCY} $opts \
    -o /tmp/luet-entropy/task_${n_task}.yaml

  if [ -z "${SKIP_FIRE}" ] ; then
    mottainai-cli task create --yaml /tmp/luet-entropy/task_${n_task}.yaml
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
