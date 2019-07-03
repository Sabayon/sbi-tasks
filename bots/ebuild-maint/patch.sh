#!/bin/bash
# Author: mudler@gentoo.org
SRC=$1 # ebuild which is fork. behind from upstream
TARGET=$2 # upstream latest ebuild. both in this format: sys-apps/systemd/systemd-xxx.ebuild
STRATEGY="${STRATEGY:-1}"
OVERLAY_DIR="${OVERLAY_DIR:-/var/lib/layman/sabayon-distro}"

set -ex

WORKDIR=${WORKDIR:-$PWD}
[[ ! -d "$WORKDIR/gentoo" ]] && git clone https://github.com/gentoo/gentoo $WORKDIR/gentoo

pushd $WORKDIR/gentoo
	COMMIT=$(git rev-list -n 1 HEAD -- $SRC)
	git checkout $COMMIT^ -- $SRC
	if [ $STRATEGY -eq 1 ]
	then
		diff -Naurp $SRC $TARGET > $WORKDIR/diff.patch || true 
	fi

popd

pushd $OVERLAY_DIR
	if [ $STRATEGY -eq 1 ]
	then
		cp -rfv $OVERLAY_DIR/$SRC $OVERLAY_DIR/$TARGET
	else
		cp -rfv $WORKDIR/gentoo/$TARGET $OVERLAY_DIR/$TARGET
		diff -Naurp $WORKDIR/gentoo/$SRC $OVERLAY_DIR/$SRC > $WORKDIR/diff.patch || true 
	fi
	package=$(dirname $WORKDIR/gentoo/$SRC)
	[ -d $package/files ] && cp -rfv $package/files  $(dirname $OVERLAY_DIR/$TARGET)
	patch -u $OVERLAY_DIR/$TARGET -p1 -i $WORKDIR/diff.patch -f --merge
