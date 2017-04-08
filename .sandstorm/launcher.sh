#!/bin/bash
set -euo pipefail

UWSGI_SOCKET_FILE=/var/run/zim_uploader_uwsgi.sock

# Some stuff nginx needs. /var is per-instance
mkdir -p /var/run
mkdir -p /var/log/nginx
mkdir -p /var/lib/nginx
mkdir -p /var/data
mkdir -p /var/data/chunking

cd /var

# Start the Zim file uploader via uwsgi if there's no Zim file
HOME=/var uwsgi \
      --socket $UWSGI_SOCKET_FILE \
      --plugin python \
      --virtualenv /opt/app/zim_uploader/env \
      --python-path /opt/app/zim_uploader/uploader \
      --wsgi-file /opt/app/zim_uploader/uploader/app.py &

/opt/app/scripts/kiwix_delayed.sh &

# Wait for uwsgi to bind its socket
while [ ! -e $UWSGI_SOCKET_FILE ] ; do
    echo "waiting for uwsgi for zim uploader to be available at $UWSGI_SOCKET_FILE"
    sleep .2
done

# Start nginx.
/usr/sbin/nginx -c /opt/app/.sandstorm/service-config/nginx.conf -g "daemon off;"
