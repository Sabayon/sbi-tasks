#!/bin/bash

set -e
set -x
export KTRACKER="${KTRACKER:-scripts/kernel-autobump-tracker}"
export TASK="${TASK:-/root/repo/bots/kernel-tracker/kernel-bump.yaml}"
containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

trackKernel () {
    local kernel="$1"

    IFS=. read major minor <<EOF
${kernel##*-}
EOF

    echo './kernel-autobump "${KERNEL_DIR}" stable origin '$major'.'$minor' sabayon- "'$major'\.'$minor'\.[0-9999]"' >> "$KTRACKER"
    git add "$KTRACKER"
    git commit -m "Track ${kernel}.x kernels"
    export V="<version>"
    emerge-webrsync
    eix-sync || true
    LAST_FW=${LAST_FW:-$(eix sys-kernel/linux-firmware -u --format '<bestversion:V>')}
    LAST_KN=$(grep 'KERNEL_VERSION_BUMP=' $TASK | sed 's/.*=//g')
    sed -i 's/^- FIRMWARE_VER=.*/- FIRMWARE_VER='$LAST_FW'/' $TASK
    sed -i 's/^- KERNEL_VERSION_BUMP=.*/- KERNEL_VERSION_BUMP='$major'.'$minor'/' $TASK
    sed -i 's/^- KERNEL_BASE=.*/- KERNEL_BASE='$LAST_KN'/' $TASK
    git add $TASK
    git commit -m "Update kernel-bumper task for ${major}.${minor}"
}

KERNEL_VERSIONS=${KERNEL_VERSIONS:-$(curl -s https://www.kernel.org/releases.json | jq '.releases[].version' -r | sed -nre 's/^([0-9]+\.)([0-9]+).*/\1\2/p')}
SAB_BRANCHES=${SAB_BRANCHES:-$(git ls-remote --heads https://github.com/Sabayon/kernel | sed -nre 's/.*refs\/heads\/(.*)/\1/p')}

echo "Sabayon branches:" $SAB_BRANCHES
echo "Latest kernel stable (active) branches:" $KERNEL_VERSIONS

for i in $KERNEL_VERSIONS
do
   if containsElement $i $SAB_BRANCHES
   then
    echo "[OK] We have $i"
   else
    echo "[MISSING] We need to track $i"
    trackKernel $i
    exit 0
   fi
done
