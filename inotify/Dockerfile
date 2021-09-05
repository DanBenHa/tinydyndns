FROM alpine

MAINTAINER Daniel Hähnke

#
# Install all required dependencies.
#

RUN apk --update upgrade && \
    apk add --update curl inotify-tools jq && \
    rm -rf /var/cache/apk/*


#
# Add named init script.
#

ADD init.sh /init.sh
RUN chmod 750 /init.sh


#
# Define container settings.
#

# WORKDIR /tmp


#
# Start named.
#

CMD ["/init.sh"]
