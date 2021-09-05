#!/bin/sh

#
# Script options (exit script on command fail).
#
set -e

CURL_OPTIONS_DEFAULT=
SIGNAL_DEFAULT="SIGHUP"
SIGNAL_DEFAULT="make_restart.sh"
INOTIFY_EVENTS_DEFAULT="create,delete,modify,move"
INOTIFY_OPTONS_DEFAULT='--monitor --exclude=*.sw[px]'

#
# Display settings on standard out.
#
echo "inotify settings"
echo "================"
echo
echo "  Container:        ${CONTAINER}"
echo "  Volumes:          ${VOLUMES}"
echo "  Curl_Options:     ${CURL_OPTIONS:=${CURL_OPTIONS_DEFAULT}}"
echo "  Signal:           ${SIGNAL:=${SIGNAL_DEFAULT}}"
echo "  Inotify_Events:   ${INOTIFY_EVENTS:=${INOTIFY_EVENTS_DEFAULT}}"
echo "  Inotify_Options:  ${INOTIFY_OPTONS:=${INOTIFY_OPTONS_DEFAULT}}"
echo

#
# Inotify part.
#
echo "[Starting inotifywait...]"
inotifywait -e ${INOTIFY_EVENTS} ${INOTIFY_OPTONS} "${VOLUMES}" | \
    while read -r notifies;
    do
    	echo "$notifies"
        exec_id=$(curl \
            -s \
            --data-binary "@/post" \
            -X POST \
            -H "Content-Type: application/json" \
            --unix-socket /var/run/docker.sock \
            http://localhost/containers/${CONTAINER}/exec \
            | jq -r ".Id")
        curl -s --data-binary "@/start" \
            -X POST \
            -H "Content-Type: application/json" \
            --unix-socket /var/run/docker.sock \
            http://localhost/exec/${exec_id}/start
    done
