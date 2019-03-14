#!/bin/bash

pushd /root/repo
OBSOLETES="$(sabayon-detectobsolete --arch $ARCH --overlay /root/repo 2>/dev/null | grep -v "Checking"  | grep -v "Obsoletes found" | uniq | sort | sed '/^\s*$/d')"

for i in $OBSOLETES; do
    git rm -r "$i" || true
    git commit -m "[$i] Drop, using portage version" || true
done

popd
