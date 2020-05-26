#!/bin/bash

set -e

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

wget https://dispatcher.sabayon.org/sbi/namespace/luet-cross-bin/luet-latest-linux-amd64 -O /usr/bin/luet
chmod a+x ${LUET_BIN}

echo "Ready for the game!"

msg () {
  echo "====================================================="
  echo $1
  echo "====================================================="

  return 0
}

msg "LUET CONFIG:"
$LUET_BIN config
msg "====================================================="

msg "LUET REPO UPDATE:"
$LUET_BIN repo update
msg "====================================================="
sleep 1

msg "LUET RECLAIM:"
$LUET_BIN reclaim
msg "====================================================="
sleep 1

msg "INSTALLED PACKAGES:"
$LUET_BIN search --installed .
msg "====================================================="
sleep 1

msg "LUET UPGRADE:"
$LUET_BIN upgrade
sleep 1

