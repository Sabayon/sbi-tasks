#!/bin/bash
# Assumes master is aligned up to upstream, and develop contains your changes 

ORIGIN_BRANCH="${ORIGIN_BRANCH:-master}"
CHERRY_BRANCH="${CHERRY_BRANCH:-master}"

pushd /root/repo
git checkout $WORK_BRANCH
COMMITS=$(git cherry $CHERRY_BRANCH | awk '{ print $2 }')
for i in $COMMITS; do
    git checkout $ORIGIN_BRANCH
    git checkout -b "branch-$i"
    git cherry-pick "$i"
    git push -v -f -u origin "branch-$i"
    # Branch is ready now to open PR
    hub pull-request $HUB_ARGS -m "$(git log -1 --pretty=%B)"
    git checkout $WORK_BRANCH
done
popd
