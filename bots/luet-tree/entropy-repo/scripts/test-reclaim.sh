#!/bin/bash

set -e

# Packages to install before run luet reclaim
PACKAGES="${PACKAGES:-""}"

LUET_BIN=/usr/bin/luet
LUET_REPO_BRANCH=develop
#LUET_REPO_FILE=sabayonlinux.org-stable.yml
LUET_REPO_FILE=sabayonlinux.org-dev.yml
LUET_REPO_URL=${LUET_REPO_URL:-https://raw.githubusercontent.com/Luet-lab/luet-entropy-repo}
LUET_REPO_CONF_PATH=${LUET_REPO_CONF_PATH:-${LUET_REPO_URL}/$LUET_REPO_BRANCH/conf/repos.conf.d}
LUET_REPO_CONF=${LUET_REPO_CONF:-${LUET_REPO_CONF_PATH}/${LUET_REPO_FILE}}

mkdir -p /etc/luet/repos.conf.d/

echo "Downloading luet configs..."
wget ${LUET_REPO_URL}/${LUET_REPO_BRANCH}/conf/luet-dso.yaml -O /etc/luet/.luet.yaml
wget ${LUET_REPO_CONF} -O /etc/luet/repos.conf.d/${LUET_REPO_FILE}

wget https://downloads.svc.sabayon.org/luet-cross-bin/luet-latest-linux-amd64 -O /usr/bin/luet
chmod a+x ${LUET_BIN}

find /etc/luet

msg () {
  echo "====================================================="
  echo $1
  echo "====================================================="

  sleep 1

  return 0
}

if [ "${PACKAGES}" != "" ] ; then
  msg "Install entropy packages: ${PACKAGES}"
  export ACCEPT_LICENSE=*
  equo update && equo upgrade && equo i ${PACKAGES}
fi

msg "Ready for the game!"


msg "LUET CONFIG:"
$LUET_BIN config
msg "====================================================="

msg "LUET REPO UPDATE:"
$LUET_BIN repo update
msg "====================================================="

msg "LUET RECLAIM:"
$LUET_BIN reclaim
msg "====================================================="

msg "INSTALLED PACKAGES:"
$LUET_BIN search --installed . -o yaml > result/installed_pkgs.yaml
cat result/installed_pkgs.yaml
msg "====================================================="

msg "LUET UPGRADE:"
$LUET_BIN upgrade

