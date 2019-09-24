#!/bin/bash
# Author: Daniele Rondina, geaaru@sabayonlinux.org

REPO_ARCH="${REPO_ARCH:-arm}"
TASK_LXD="${TASK_LXD:-0}"
TASK_QUEUE="${TASK_QUEUE:-arm_injector}"
MCLI="${MCLI:-mottainai-cli}"

main () {
  [ -n "${MOTTAINAI_CLI_PROFILE}" ] || {
    echo "Missing MOTTAINAI_CLI_PROFILE variable"
    return 1
  }

  [ -n "${REPOSITORY}" ] || {
    echo "Missing REPOSITORY variable"
    return 1
  }

  [ -n "${PKGS}" ] || {
    echo "Missing PKGS variable"
    return 1
  }

  local conf="next/${REPO_ARCH}/${REPOSITORY}/repo.tmpl.values"
  local tmp_task="/tmp/${REPOSITORY}-injector-task.yaml"
  local mcli_opts="-l ${conf}"

  if [ "$TASK_LXD" = 1 ] ; then
    mcli_opts="${mcli_opts} -s LxdType=1"
  fi

  echo "Removing pkgs ${PKGS} from repo ${REPOSITORY} (${REPO_ARCH})..."

  ${MCLI} task compile next/${REPO_ARCH}/repo-injector.tmpl \
        ${mcli_opts} \
        -s ArmQueue="${TASK_QUEUE}" \
        -s PkgsToRemove="${PKGS}" \
        -s SkipInject=1 \
        -o ${tmp_task} || return 1

  if [ -z "$SKIP_FIRE" ] ; then
    ${MCLI} task create --yaml ${tmp_task} || return 1
  fi

  if [ -z "$SKIP_REMOVE" ] ; then
    rm ${tmp_task} || true
  fi

  return 0
}

main $@
exit $?

# vim: ts=2 sw=2 expandtab filetype=sh
