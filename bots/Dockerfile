FROM sabayon/builder-amd64:latest

ENV ACCEPT_LICENSE=*
ENV INSTALL_DIRECTORY=/usr/bin
RUN equo up && equo i sabayon-sark enman jq eix git git-lfs docker hub dev-lang/go && equo cleanup
RUN enman add https://downloads.svc.sabayon.org/devel/devel && equo up && equo install dev-perl/App-Nopaste dev-perl/App-CLI dev-perl/Child dev-perl/Carp-Always dev-perl/Config-Simple virtual/perl-Digest-MD5 virtual/perl-Encode virtual/perl-File-Path dev-perl/IPC-Run3 dev-perl/Git-Sub dev-perl/HTTP-Message dev-perl/libwww-perl dev-perl/regexp-common virtual/perl-Term-ANSIColor dev-perl/TermReadKey dev-perl/Import-Into dev-perl/Module-Build euscan dev-perl/App-cpanminus docker-companion dev-util/mottainai-cli replicant && equo cleanup
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
RUN eselect profile set 5

ENTRYPOINT [ "/bin/bash" ]