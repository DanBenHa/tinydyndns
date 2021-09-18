FROM alpine

MAINTAINER Daniel Hähnke

RUN apk --update upgrade && \
    apk add --update curl inotify-tools jq tini && \
    rm -rf /var/cache/apk/*;

ADD init.sh /init.sh
RUN chmod 750 /init.sh

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/init.sh"]
