#!/bin/bash
set -x
set -e

equo up && equo i dev-lang/go
mkdir go
export GOPATH=$PWD/go
export PATH="$PATH:$GOPATH/bin"
WORKDIR=$PWD
VENDORDIR="github.com/MottainaiCI"

mkdir -p go/src/${VENDORDIR}

for SUBPROJECT in "mottainai-server" "mottainai-cli" "mottainai-agent" "replicant"
do
  git clone https://${VENDORDIR}/${SUBPROJECT} go/src/${VENDORDIR}/${SUBPROJECT}
  pushd go/src/${VENDORDIR}/${SUBPROJECT}
  [ -z "${PROJECT_BRANCH}" ] || {
    git checkout ${PROJECT_BRANCH}
  }
  make deps
  make multiarch-build
  mv release/* $WORKDIR/artefacts/
  popd
done
