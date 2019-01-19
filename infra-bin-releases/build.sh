#!/bin/bash
set -x
set -e

equo up && equo i dev-lang/go
mkdir go
export GOPATH=$PWD/go
export PATH="$PATH:$GOPATH/bin"
WORKDIR=$PWD

mkdir -p go/src/github.com/MottainaiCI

for SUBPROJECT in "mottainai-server" "mottainai-cli" "mottainai-agent" "replicant"
do
	git clone https://github.com/MottainaiCI/${SUBPROJECT} go/src/github.com/MottainaiCI/${SUBPROJECT}
	pushd go/src/github.com/MottainaiCI/${SUBPROJECT}
  make deps
  make multiarch-build
  mv release/* $WORKDIR/artefacts/
  popd
done
