#!/bin/bash
set -euo pipefail

UWSGI_SOCKET_FILE=/var/run/zim_uploader_uwsgi.sock

# Some stuff nginx needs. /var is per-instance
mkdir -p /var/run
mkdir -p /var/log/nginx
mkdir -p /var/lib/nginx
mkdir -p /var/data
mkdir -p /var/data/chunking

if [ -f /var/data/chunking/kiwix.zim ]; then
    rm /var/data/chunking/*
fi

if [ ! -f /var/data/chunking/* ]; then
    dd if=/dev/urandom bs=1 count=16 | base64 > /var/secret_key
fi

cd /var

# Start the Zim file uploader via uwsgi if there's no Zim file
HOME=/var uwsgi \
      --socket $UWSGI_SOCKET_FILE \
      --plugin python3 \
      --python-path /zim_uploader/uploader \
      --wsgi-file /zim_uploader/uploader/app.py &

/kiwix-run/kiwix-delayed.sh &

# Wait for uwsgi to bind its socket
while [ ! -e $UWSGI_SOCKET_FILE ] ; do
    echo "waiting for uwsgi for zim uploader to be available at $UWSGI_SOCKET_FILE"
    sleep .2
done

sleep .2

# Start nginx.
/usr/sbin/nginx -c /service-config/nginx.conf -g "daemon off;"
