FROM alpine

RUN apk update && apk --no-cache add bind-tools coreutils file ncurses
RUN addgroup -S app && adduser -S app -G app
ENV PS1='💉 \[\033[1;36m\]\u@\h \[\033[1;34m\]\W\[\033[0;35m\] \[\033[1;36m\]$ \[\033[0m\]'
USER app

ENTRYPOINT ["sleep","infinity"]