#!/bin/bash

set -x
set -e

#git branch -D ${KERNEL_VERSION_BUMP} || true
git remote add stable git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
git fetch stable
git checkout ${KERNEL_BASE}
cp -rfv sabayon sabayon-${KERNEL_BASE}
git checkout v${KERNEL_VERSION_BUMP}
git checkout -b ${KERNEL_VERSION_BUMP}
cp -rfv sabayon-${KERNEL_BASE} sabayon
[ -d "sabayon/patches" ] && git am < sabayon/patches/*
git add sabayon
git commit -m 'sabayon: add distro stuff'
cp sabayon/config/sabayon-amd64.config .config
make olddefconfig
cp .config sabayon/config/sabayon-amd64.config
git add sabayon/config
git commit -m 'sabayon: add configs'
git push -fv --set-upstream origin ${KERNEL_VERSION_BUMP}

mkdir -p $DIFFSDIR || true
bash $WORK/scripts/tag-version.sh sabayon-${KERNEL_VERSION_BUMP}
pushd /root/repo
git checkout $WORK_BRANCH
git push -fv --set-upstream origin $WORK_BRANCH
hub pull-request -m "Add new $KERNEL_VERSION_BUMP kernel"
