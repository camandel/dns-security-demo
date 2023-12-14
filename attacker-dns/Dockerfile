FROM alpine:3.18.5

RUN apk update && apk --no-cache add dnsmasq bind-tools coreutils sl file
RUN cp /usr/bin/sl /root/malware
COPY dnsmasq.conf /etc/dnsmasq.conf
ENV PS1='💀 \[\033[1;36m\]\u@\H \[\033[1;34m\]\W\[\033[0;35m\] \[\033[1;36m\]# \[\033[0m\]'

ENTRYPOINT ["dnsmasq","--no-daemon"]