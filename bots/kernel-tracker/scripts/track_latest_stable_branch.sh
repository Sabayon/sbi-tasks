#!/bin/bash

export KTRACKER="${KTRACKER:-scripts/kernel-autobump-tracker}"

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
}

KERNEL_VERSIONS=${KERNEL_VERSIONS:-$(curl -s https://www.kernel.org/releases.json | jq '.releases[].version' -r | sed -nre 's/^([0-9]+\.)([0-9]+)\..*/\1\2/p')}
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
   fi
done