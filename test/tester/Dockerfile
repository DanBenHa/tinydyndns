FROM alpine

RUN \
    apk update; \
    apk add tini openssh;
ADD hostkey.pub /etc/hostkey.pub
ADD hostkey /etc/ssh/hostkey


ENTRYPOINT ["/sbin/tini", "--"]
