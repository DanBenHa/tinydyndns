FROM alpine 
MAINTAINER Daniel Hähnke

RUN \
 apk update; \
 apk add openssh grep sipcalc tini;

# cleanup
RUN \
 rm -r /var/cache/apk/*;

RUN \
    adduser -D -s /update.sh dyndns; \
    touch /home/dyndns/.hushlogin; \
    echo dyndns:changeme | chpasswd;

RUN ssh-keygen -A;
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
ADD update.sh /update.sh

EXPOSE 22/tcp
ENTRYPOINT ["/sbin/tini", "--"]
CMD \
    mkdir /home/dyndns/.ssh; \
    cp /tmp/authorized_keys /home/dyndns/.ssh/authorized_keys; \
    chown dyndns:dyndns /home/dyndns/.ssh/authorized_keys; \
    chmod 600 /home/dyndns/.ssh/authorized_keys; \
    echo $IP4_DEFAULT > /home/dyndns/IP4_DEFAULT; \ 
    echo $IP6_DEFAULT > /home/dyndns/IP6_DEFAULT; \ 
    /usr/sbin/sshd -D;
