#!/bin/bash
#
# This script automatically bumps the version of Sabayon
# ebuilds.

. /etc/profile

VERSION="${VERSION:-$(/bin/date -u --date="$(/bin/date -u +%g-%m-%d) +1 month" "+%g.%m")}"
OVERLAY_BASE_URL="git@github.com:Sabayon"
OVERLAY_BASE_DIR="${OVERLAY_BASE_DIR:-${HOME}}"

PACKAGES=(
    "app-misc/sabayon-version sabayon-distro"
)


bump_package() {
    local overlay_dir="${1}"
    local overlay="${2}"
    local package="${3}"
    local version="${4}"
    local package_name=$(basename "${package}")
    local skel_file="${package_name}.skel"
    local package_file="${package_name}-${version}.ebuild"

    (
        cd "${overlay_dir}/${package}" || exit 1
        cp "${skel_file}" "${package_file}" || exit 1
        ebuild "${package_file}" manifest || exit 1
        git add "${package_file}" || exit 1
        git add -u . || exit 1
        git commit -m "[${package}] automatic version bump to ${version}" \
            || exit 1

        local done=0
        for x in $(seq 5); do
            git push && {
                done=1;
                break;
            }
            sleep 5
        done
        if [ "${done}" = "0" ]; then
            echo "Unable to push, giving up after 5 tries" >&2
            echo "Please bump ${package} manually to ${version}" >&2
            exit 1
        fi
    ) || return 1
}


bumped=()
for info in "${PACKAGES[@]}"; do
    data=( ${info} )
    package="${data[0]}"
    bumped+=( "${package}" )
    overlay="${data[1]}"
    overlays_dir="${OVERLAY_BASE_DIR}/automatic-overlays"
    overlay_dir="${overlays_dir}/${overlay}"

    mkdir -p "${overlays_dir}" || exit 1
    bump_package "${OVERLAY_BASE_DIR}" "${overlay}" "${package}" \
        "${VERSION}" || exit 1
done

echo "The following packages have been updated to version: ${VERSION}" >&2
echo "${bumped[@]}" >&2
echo >&2
echo "Make sure to have these packages bumped in Entropy as soon as possible." >&2
exit 0
