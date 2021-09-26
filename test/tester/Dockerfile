FROM alpine

RUN \
    apk update; \
    apk add tini openssh busybox-extras bind-tools;
ADD hostkey.pub /etc/ssh/hostkey.pub
ADD hostkey /etc/ssh/hostkey
RUN chmod 600 /etc/ssh/hostkey*


ENTRYPOINT ["/sbin/tini", "--"]
