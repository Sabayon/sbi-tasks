#!/bin/bash
# Assumes master is aligned up to upstream, and develop contains your changes 

cd /root/repo
git checkout $WORK_BRANCH
COMMITS=$(git cherry master | awk '{ print $2 }')
for i in $COMMITS; do
    git checkout master
    git checkout -b "branch-$i"
    git cherry-pick "$i"
    git push -v -u origin "branch-$i"
    # Branch is ready now to open PR
    hub pull-request -m "$(git log -1 --pretty=%B)"
    git checkout $WORK_BRANCH
done
 
