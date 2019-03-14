#!/bin/bash

# Install the autobumper
equo i dev-perl/App-Nopaste dev-perl/App-CLI dev-perl/Child dev-perl/Carp-Always dev-perl/Config-Simple virtual/perl-Digest-MD5 virtual/perl-Encode virtual/perl-File-Path dev-perl/IPC-Run3 dev-perl/Git-Sub dev-perl/HTTP-Message dev-perl/libwww-perl dev-perl/regexp-common virtual/perl-Term-ANSIColor dev-perl/TermReadKey dev-perl/Import-Into dev-perl/Module-Build euscan dev-perl/App-cpanminus  > /dev/null 2>&1 || true

rm -rfv App-witchcraft || true
git clone https://github.com/Spike-Pentesting/App-witchcraft.git
pushd App-witchcraft
sed -i 's|automatically added/updated by witchcraft|Version bump|g' lib/App/witchcraft/Plugin/Git.pm
cpanm --installdeps -n . || true
perl Build.PL
./Build
./Build install
popd

# Create a default config
mkdir -p /root/.witchcraft || true
echo "PLUGINS: Entropy, Gentoo, Git" > /root/.witchcraft/witchcraft.conf
echo "EQUO_DEPINSTALL: 1" >> /root/.witchcraft/witchcraft.conf
echo "EMERGE_UPGRADE_OPTS: -n" >> /root/.witchcraft/witchcraft.conf
echo "GIT_REPOSITORY:/root/repo" >> /root/.witchcraft/witchcraft.conf

# Fix Broken euscan (install from 9999)
pushd /usr/portage/app-portage/euscan/
ekeyword amd64 euscan-9999.ebuild
ebuild euscan-9999.ebuild digest
ebuild euscan-9999.ebuild merge
popd


