FROM alpine 
MAINTAINER Daniel Hähnke

RUN \
 apk update; \
 apk add gcc g++ make curl patch;

# install daemontools
# TODO: checksums
RUN \
 mkdir /daemontools; \
 curl -o /daemontools/daemontools-0.76.tar.gz https://cr.yp.to/daemontools/daemontools-0.76.tar.gz; \
 cd /daemontools; \
 tar zxvf daemontools-0.76.tar.gz; \
 rm -f daemontools-0.76.tar.gz; \
 cd admin/daemontools-0.76/; \
 echo gcc -O2 -include /usr/include/errno.h > src/conf-cc; \
 ./package/install; 

# tinydns: apply ipv6 patch
# TODO: checksums
RUN \
 curl -o /tmp/djbdns-1.05.tar.gz https://cr.yp.to/djbdns/djbdns-1.05.tar.gz; \
 curl -o /tmp/djbdns-1.05-test28.diff.xz https://www.fefe.de/dns/djbdns-1.05-test28.diff.xz; \
 cd /tmp; \
 tar zxvf djbdns-1.05.tar.gz;  \
 cd djbdns-1.05/; \
 xzcat ../djbdns-1.05-test28.diff.xz | patch -p1; \
 echo gcc -O2 -include /usr/include/errno.h > conf-cc; \
 make; \
 make setup check; 

RUN \
 adduser -D tinydns; \
 adduser -D dnslog; \
 tinydns-conf tinydns dnslog /etc/tinydns 0.0.0.0;

# cleanup
RUN \
 apk del gcc g++ patch curl; \
 rm -r /tmp/*; \
 rm -r /var/cache/apk/*;

EXPOSE 53/udp

CMD \
 cd /etc/tinydns/root; \
 make; \
 cd /etc/tinydns; \
 ./run;
