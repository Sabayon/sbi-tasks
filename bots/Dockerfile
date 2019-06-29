FROM sabayon/builder-amd64:latest

ENV ACCEPT_LICENSE=*
ENV INSTALL_DIRECTORY=/usr/bin
RUN equo up && equo i git docker hub dev-lang/go && equo cleanup
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
ENTRYPOINT [ "/bin/bash" ]