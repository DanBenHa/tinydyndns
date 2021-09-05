#!/bin/sh
cd /etc/tinydns/root
make
cd /etc/tinydns
./run
# Dummy process below is executed after the first tinydns instance is killed.
# This keeps the container alive.
tail -f /dev/null
