FROM alpine 
MAINTAINER Daniel Hähnke

RUN \
 apk update; \
 apk add openssh grep sipcalc;

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

CMD \
 /usr/sbin/sshd -D;
