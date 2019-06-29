FROM sabayon/builder-amd64:latest

ENV ACCEPT_LICENSE=*

RUN equo up && equo i git hub dev-lang/go && equo cleanup

ENTRYPOINT [ "/bin/bash" ]