#!/bin/bash
# Needs sabayon-sark. Used to generate JSONP data for the community-website indexer
# Author: mudler <mudler@gentoo.org>

TEMPWORK=$(mktemp -d)
trap "rm -rf $TEMPWORK" EXIT
. /sbin/sark-functions.sh


REPOS_TO_SYNC=(
    "mudler"
    "community"
    "devel"
    "haskell"
    "rust"
    "sihnon-common"
    "sihnon-desktop"
    "sihnon-server"
)
export WORKSPACE="${WORKSPACE:-$PWD}"

export ARCHES="${ARCHES:-amd64}"
export SYNC_URL="${SYNC_URL:-http://dispatcher.sabayon.org/namespace/}"
export VAGRANT_DIR="${TEMPWORK}/"


pushd $TEMPWORK

  for a in $ARCHES
  do
    echo "Arch: $a"
    for i in "${REPOS_TO_SYNC[@]}"
    do
      echo $i >> AVAILABLE_REPOSITORIES
        mkdir -p "${i}"
        wget "$SYNC_URL/${i}/${i}/PKGLIST-${a}" -q -O "${i}/PKGLIST-${a}"
    done
  done
  sark-genreposmeta || exit 1
  cp -rfv metadata.json "$WORKSPACE"/ || exit 1

popd

cat metadata.json || exit 1
rm -rf $TEMPWORK
