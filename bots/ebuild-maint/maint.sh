#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

OVERLAY_DIR="${OVERLAY_DIR:-/var/lib/layman/sabayon-distro}"
WORKDIR="${WORKDIR:-$DIR}"


function tryPatch {
	local SRC=$1
	local TARGET=$2
	local PACKAGE=$3
	local BUMP_VERSION=$4
	echo "$CAT/$P-$LATEST_PORTAGE.ebuild not present in overlay. Latest in overlay is: $LATEST_OVERLAY"
	echo $SRC $TARGET
	set +e
	$DIR/try_patch.sh $SRC $TARGET
	patchret=$?
	set -e
	pushd $OVERLAY_DIR
			pushd $PACKAGE
				ebuild $(basename $TARGET) digest || true
			popd
		rm -rfv $TARGET.orig || true
		git add --all .
		if [ $patchret -eq 0 ];
		then
			git commit -m "[$PACKAGE] Version bump to $BUMP_VERSION" || true
		else
			git commit -m "[$PACKAGE] Version bump to $BUMP_VERSION" -m "Automatic merge failed, merge conflicts must be manually solved" || true
		fi
	popd
	return 0
}

export KEEP_PREVIOUS_VERSIONS=1
export OUTPUT_REMOVED=0

[[ ! -d "$WORKDIR/gentoo" ]] && git clone https://github.com/gentoo/gentoo $WORKDIR/gentoo

for c in $WORKDIR/gentoo/*; do
    [ -d "$c" ] || continue
    CAT=$(basename $c)

    [ $CAT == "profiles" ] && continue

    for p in $c/*; do
    	P=$(basename $p)
    	[ -d "$p" ] || continue
		if [ -d "$OVERLAY_DIR/$CAT/$P" ];
		then
			export PACKAGES=$(ls "$OVERLAY_DIR/$CAT/$P" | grep ebuild | sed 's/\.ebuild//' | xargs echo )
			echo "PACKAGES: $PACKAGES"
			echo "Forked ebuild in common: $CAT/$P"
			export V="<version>"
			export OVERLAYS_LIST=all 
			export PRINT_COUNT_ALWAYS=never 
			set +e
			LATEST_PORTAGE=$(eix -e $CAT/$P --testing --pure-packages --format '<bestversion*:V>')
			LATEST_OVERLAY=$(sark-version-sanitizer)
			set -e	
			for i in $LATEST_OVERLAY
			do 
				[ -e "$OVERLAY_DIR/$CAT/$P/$P-$LATEST_PORTAGE.ebuild"  ] && break
				tryPatch "$CAT/$P/${i}.ebuild" "$CAT/$P/$P-$LATEST_PORTAGE.ebuild" "$CAT/$P" $LATEST_PORTAGE
			done
		fi
    done
done
