FROM alpine

RUN apk update && apk --no-cache add dnsmasq bind-tools coreutils sl file
COPY dnsmasq.conf /etc/dnsmasq.conf
ENV PS1='💀 \[\033[1;36m\]\u@\h \[\033[1;34m\]\W\[\033[0;35m\] \[\033[1;36m\]# \[\033[0m\]'

ENTRYPOINT ["dnsmasq","--no-daemon"]