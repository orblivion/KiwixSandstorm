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

if [ ! -f /var/data/kiwix.zim ] ; then
  # Start the Zim file uploader via uwsgi if there's no Zim file
  HOME=/var uwsgi \
        --socket $UWSGI_SOCKET_FILE \
        --plugin python \
        --virtualenv /opt/app/zim_uploader/env \
        --python-path /opt/app/zim_uploader/uploader \
        --wsgi-file /opt/app/zim_uploader/uploader/app.py &

  # Start a script that waits for the zim file to exist, and then starts kiwix.
  # This one is suboptimal, because it will not be ready instantly after the
  # zim file is available. That's why on restarts of the grain, it will skip
  # this and immediately run kiwix, and wait before starting nginx.
  /opt/app/scripts/kiwix_delayed.sh &

  # Wait for uwsgi to bind its socket
  while [ ! -e $UWSGI_SOCKET_FILE ] ; do
      echo "waiting for uwsgi for zim uploader to be available at $UWSGI_SOCKET_FILE"
      sleep .2
  done
else
  # libkiwix.so
  export LD_LIBRARY_PATH=/usr/local/lib/x86_64-linux-gnu/:/opt/app/openzim/zimlib/src/.libs/:/opt/app/xapian/xapian-core/.libs/:/opt/app/pugixml/
  kiwix-serve --port=8080 /var/data/kiwix.zim &

  # Hopefully enough time to make sure kiwix-serve started, since we don't have the benefit of a sock file.
  sleep .2;
fi

# Start nginx.
/usr/sbin/nginx -c /opt/app/.sandstorm/service-config/nginx.conf -g "daemon off;"
