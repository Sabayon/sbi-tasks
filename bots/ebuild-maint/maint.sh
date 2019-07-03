#!/bin/bash
set -e
OVERLAY_DIR="${OVERLAY_DIR:-/var/lib/layman/sabayon-distro}"
WORKDIR="${WORKDIR:-$PWD}"

for c in $WORKDIR/gentoo/*; do
    [ -d "$c" ] || continue
    CAT=$(basename $c)
    [ $CAT == "profiles" ] && continue
    for p in $c/*; do
    	P=$(basename $p)
    	[ -d "$p" ] || continue
	if [ -d "$OVERLAY_DIR/$CAT/$P" ];
	then
	   echo "Forked ebuild present: $CAT/$P"
	   ls "$OVERLAY_DIR/$CAT/$P"
	   ls $WORKDIR/gentoo/$CAT/$P
	fi
    done
done
