#!/bin/bash

export DIFFSDIR="${DIFFSDIR=:-storage}"
export OVERLAY="${OVERLAY:-$HOME/repos/sabayon-distro}"


# Check target tag
[[ -z "$1" ]] && echo "usage: $0 <new-version>" >&2 && exit 1
tag="$1"

name="${tag/-*}"
version="${tag/${name}-}"
kernel_branch="$(echo ${version} | cut -d. -f 1-2)"
[[ -z "${name}" ]] && echo "invalid name for tag $tag" >&2 && exit 1
[[ -z "${version}" ]] && echo "invalid version for tag $tag" >&2 && exit 1
[[ -z "${kernel_branch}" ]] && echo "invalid kernel_branch for tag $tag" >&2 \
    && exit 1

echo "Making the tarballs..."

(
    flock -x 9 || exit 1

    echo "Generating the diff: ${kernel_branch} -> ${tag}..."
    kernel_diff="${kernel_branch}-${tag}.patch.xz"
    ionice git diff --binary "v${kernel_branch}..${tag}" | \
        xz > "${kernel_diff}" || exit 1

    mv "${kernel_diff}" "${DIFFSDIR}"/ || exit 1
) 9> /tmp/.kernel-tag-version-tarball.lock

echo "Updating the overlay..."

(
    flock -x 9 || exit 1

    cd "${OVERLAY}" || exit 1

    script_file="scripts/${name}-kernel-bump.sh"
    if [ -x "${script_file}" ]; then
        echo "Executing the bump script..."
        bash "${script_file}" "${version}" || exit 1
        git commit --quiet -m \
            "[sys-kernel/*${name}*] version bump to ${version}" || exit 1
    else
        echo "No ${script_file} found" >&2
    fi
) 9> /tmp/.kernel-tag-version-overlay.lock

echo "All good"
