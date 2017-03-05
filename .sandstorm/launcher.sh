#!/bin/bash
set -euo pipefail

UWSGI_SOCKET_FILE=/var/run/zim_uploader_uwsgi.sock

# Some stuff nginx needs. Apparently it doesn't persist after build?
mkdir -p /var/run
mkdir -p /var/log/nginx
mkdir -p /var/lib/nginx

if [ ! -f /var/kiwix.zim ] ; then
  # Spawn uwsgi
  HOME=/var uwsgi \
        --socket $UWSGI_SOCKET_FILE \
        --plugin python \
        --virtualenv /opt/app/zim_uploader/env \
        --wsgi-file /opt/app/zim_uploader/app.py &

  # Start a script that waits for the zim file to exist, and then starts kiwix.
  # This one is suboptimal, because it will not be ready instantly after the
  # zim file is available. That's why on restarts of the grain, it will skip
  # this and immediately run kiwix, and wait before starting nginx.
  /opt/app/scripts/kiwix_delayed.sh &

  # Wait for uwsgi to bind its socket
  while [ ! -e $UWSGI_SOCKET_FILE ] ; do
      echo "waiting for uwsgi for zimp uploader to be available at $UWSGI_SOCKET_FILE"
      sleep .2
  done
else
  # libkiwix.so
  export LD_LIBRARY_PATH=/usr/local/lib/x86_64-linux-gnu/:openzim/zimlib/src/.libs/:xapian/xapian-core/.libs/:pugixml/
  kiwix-serve --port=8080 /var/kiwix.zim &

  # Wait for kiwix to start before sending to nginx
  until wget -qO- 127.0.0.1:8080 &> /dev/null;
  do
    echo "Waiting for kiwix to start";
    sleep .2;
  done
fi

# Start nginx.
/usr/sbin/nginx -c /opt/app/.sandstorm/service-config/nginx.conf -g "daemon off;"
