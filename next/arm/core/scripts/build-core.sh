#!/bin/bash
# Author: Geaaru <geaaru@sabayonlinux.org>
#

SABAYON_PROFILE_ID=${SABAYON_PROFILE_ID:-34}
SABAYON_EQUO_DIR="/var/lib/entropy/client/database/"

. $(dirname $(readlink -f $BASH_SOURCE))/commons.sh

SABAYON_EXTRA_MASK=(
#  "# 2017-11-26 Geaaru: Use sabayon version"
#  "app-crypt/pinentry::gentoo"
#  ""

  "# 2017-11-26 Geaaru: Use sabayon version"
  "sys-devel/gcc::gentoo"
  ""

  "# 2017-12-30 Geaaru: Mask baselayout for override of /etc/hosts file"
  "sys-apps/baselayout::gentoo"
  ""

#  "# 2018-04-07 Geaaru: Use sabayon version"
#  "dev-vcs/git::gentoo"
#  ""
)

sabayon_clean_makeconf () {

  sed -i -e 's:^PYTHON_.*::g' ${MAKE_PORTAGE_FILE}
  sed -i -e 's:^CFLAGS.*::g' ${MAKE_PORTAGE_FILE}
  sed -i -e 's:^CXXFLAGS.*::g' ${MAKE_PORTAGE_FILE}

}

sabayon_stage3_init_equo () {

  local equodir=${SABAYON_EQUO_DIR}/${SABAYON_ARCH}
  local size=""

  mkdir -p ${equodir}
  cd ${equodir}

  cat ./scripts/equo.sql | sqlite3 equo.db

  size=$(ls -l ${equodir}/equo.db  | cut -d' ' -f5)
  if [ x"$size" == x"0" ] ; then
    echo "Something go wrong on create equo.db."
    exit 1
  fi

  echo "Create equo.db database from schema correctly."
}

init () {
  uname -a

  sabayon_load_locate

  sabayon_check_etc_portage

  sabayon_set_resolvconf

  sabayon_set_default_shell

  emerge-webrsync

  sabayon_install_overlay "sabayon" 1
  sabayon_install_overlay "sabayon-distro" 1

  eselect profile list
  eselect profile set ${SABAYON_PROFILE_ID}

  sabayon_clean_makeconf
}

build () {
  export ACCEPT_LICENSE='*'
  export SAB_EMERGE_OPTS='-j --with-bdeps=y'

  for ((i = 0 ; i < ${#SABAYON_EXTRA_MASK[@]} ; i++)) ; do
    echo ${SABAYON_EXTRA_MASK[${i}]} >> \
      /etc/portage/package.mask/00-sabayon.package.mask
  done

  emerge -C $(qlist -IC dev-perl/) $(qlist -IC virtual/perl) \
    $(qlist -IC perl-core/) \
    app-crypt/pinentry \
    sys-apps/texinfo \
    sys-apps/baselayout \
    dev-python/requests \
    dev-vcs/git \
    app-text/po4a \
    media-gfx/graphite2 \
    app-eselect/eselect-python

  # Force building of bash without ebuild
  # baselayout needed for /etc/profile file
  emerge -u app-shells/bash app-crypt/gnupg sys-apps/baselayout --oneshot --quiet


  emerge ${SAB_EMERGE_OPTS} dev-perl/XML-Parser \
    sys-apps/util-linux \
    $(qgrep -JN sys-libs/readline | cut -f1 -d":" | uniq | sed -e 's:^:=:g' | grep -v "util-linux" )

  emerge sys-devel/gcc-config sys-apps/gentoo-functions -j -u


  export current_gcc=$(gcc-config -c)
  export current_gcc_version=$(echo $(gcc-config -c) | awk 'match($0, /[0-9].[0-9].[0-9]/) { print substr($0, RSTART, RLENGTH) }')

  FEATURES="-collision-protect -protect-owned" emerge -b sys-devel/base-gcc::sabayon-distro --quiet-build

  export sabayon_gcc=$(gcc-config -c)
  export sabayon_gcc_version=$(echo $(gcc-config -c) | awk 'match($0, /[0-9].[0-9].[0-9]/) { print substr($0, RSTART, RLENGTH) }')

  gcc-config ${current_gcc}

  . /etc/profile

  FEATURES="-collision-protect -protect-owned" emerge -b sys-devel/gcc::sabayon-distro  --quiet-build

  if [ ${sabayon_gcc_version} != ${current_gcc_version} ] ; then
    emerge --unmerge =sys-devel/gcc-${current_gcc_version}::gentoo || true
    # If there is same version this is not needed.
  fi

  FEATURES="-collision-protect -protect-owned" emerge -K sys-devel/base-gcc::sabayon-distro \
    sys-devel/gcc::sabayon-distro

  gcc-config ${sabayon_gcc}
  . /etc/profile

  emerge --unmerge app-admin/eselect app-text/xmlto
  emerge sandbox coreutils -j

  # Fix problem after upgrade of glibc
  sed -e 's/compat/compat files/g' -i  /etc/nsswitch.conf

  # Force installation of libaio: missing dependency of lvm2!!!
  emerge dev-libs/libaio -j

  # Needed for builder and sark-localbuild
  emerge sys-process/tini dev-python/shyaml app-portage/gentoolkit -j

  emerge --newuse --deep --with-bdeps=y -j @system --buildpkg -pv
  emerge --newuse --deep --with-bdeps=y -j @system --buildpkg

  emerge ${SAB_EMERGE_OPTS} @preserved-rebuild

  emerge sys-apps/entropy-server sys-apps/entropy app-admin/equo dev-tcltk/expect

  sabayon_set_default_shell "/bin/bash"

  # Create equo database and directory
  sabayon_stage3_init_equo

  # Calling equo rescue generate, unfortunately we have to use expect
  /usr/bin/expect ./scripts/equo-rescue-generate.exp
}


case $1 in
  init)
    init
    ;;
  build)
    build
    ;;
  *)
  echo "Use init|build"
  exit 1
esac

exit $?

