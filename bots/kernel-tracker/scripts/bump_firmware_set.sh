#!/bin/bash

set -x

sed -i "s/K_REQUIRED_LINUX_FIRMWARE_VER.*/K_REQUIRED_LINUX_FIRMWARE_VER=\"${FIRMWARE_VER}\"/" sys-kernel/linux-sabayon/linux-sabayon.skel
git add sys-kernel/linux-sabayon
git commit -m '[sys-kernel/linux-sabayon] update firmware version requirement'
echo "sys-kernel/linux-sabayon:${KERNEL_VERSION_BUMP}" > sets/intel-kernels-${KERNEL_VERSION_BUMP}
echo "sys-kernel/sabayon-sources:${KERNEL_VERSION_BUMP}" >> sets/intel-kernels-${KERNEL_VERSION_BUMP}
git add sets
git commit -m "[sets] add intel-kernels-${KERNEL_VERSION_BUMP} set"
git push



