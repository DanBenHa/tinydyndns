#!/bin/sh

cd /etc/tinydns/root
make
pid=$(pgrep tinydns)
kill $pid
cd /etc/tinydns
./run &
