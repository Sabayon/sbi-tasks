#!/bin/bash

export PACKAGES="$(ls **/**/**.ebuild | sed 's/\.ebuild$//g' | sed 's/\(.*\)\/.*\//\1\//' | xargs echo)"

TO_REMOVE="$(sark-version-sanitizer)"
KEPT=

for i in $TO_REMOVE;
do
  CAT=$(dirname $i)
  EBUILD=$CAT/**/"$(basename $i)".ebuild
  pushd $(dirname $EBUILD)  > /dev/null 2>&1
    current_ebuild="$(basename $EBUILD)"
    rm -rf $current_ebuild
    atom=$CAT/${PWD##*/}
    echo "$atom: Drop old ($current_ebuild)"
    dig=$(ls *.ebuild | sort -n | head -1)
    ebuild $dig digest > /dev/null 2>&1
    KEPT="$KEPT $atom"
  popd > /dev/null 2>&1
done

for i in $KEPT;
do
  git add $i > /dev/null 2>&1
  git commit -m "[$i] Drop old" > /dev/null 2>&1
done

exit 0
