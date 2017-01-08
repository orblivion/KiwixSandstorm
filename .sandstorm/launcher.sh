#!/bin/bash
set -euo pipefail
# This script is run every time an instance of our app - aka grain - starts up.
# This is the entry point for your application both when a grain is first launched
# and when a grain resumes after being previously shut down.
#
# This script is responsible for launching everything your app needs to run.  The
# thing it should do *last* is:
#
#   * Start a process in the foreground listening on port 8000 for HTTP requests.
#
# This is how you indicate to the platform that your application is up and
# ready to receive requests.  Often, this will be something like nginx serving
# static files and reverse proxying for some other dynamic backend service.
#
# Other things you probably want to do in this script include:
#
#   * Building folder structures in /var.  /var is the only non-tmpfs folder
#     mounted read-write in the sandbox, and when a grain is first launched, it
#     will start out empty.  It will persist between runs of the same grain, but
#     be unique per app instance.  That is, two instances of the same app have
#     separate instances of /var.
#   * Preparing a database and running migrations.  As your package changes
#     over time and you release updates, you will need to deal with migrating
#     data from previous schema versions to new ones, since users should not have
#     to think about such things.
#   * Launching other daemons your app needs (e.g. mysqld, redis-server, etc.)

# By default, this script does nothing.  You'll have to modify it as
# appropriate for your application.
cd /opt/app

if [ ! -f /var/kiwix.zim ] ; then
  # Start the Zim file uploader if there's no Zim file
  HOME=/var /opt/app/zim_uploader/env/bin/python /opt/app/zim_uploader/app.py /var &

  # Start a script that waits for the zim file to exist, and then starts kiwix.
  # This one is suboptimal, because it will not be ready instantly after the
  # zim file is available. That's why on restarts of the grain, it will skip
  # this and immediately run kiwix, and wait before starting nginx.
  /opt/app/scripts/kiwix_delayed.sh &

  until wget -qO- 127.0.0.1:5000 &> /dev/null;
  do
    echo "Waiting for zim uploader to start";
    sleep .2;
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

# Some stuff nginx needs. Apparently it doesn't persist after build?
mkdir -p /var/run
mkdir -p /var/log/nginx
mkdir -p /var/lib/nginx

# Start nginx.
/usr/sbin/nginx -c /opt/app/.sandstorm/service-config/nginx.conf -g "daemon off;"
