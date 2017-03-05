#!/bin/bash
set -euo pipefail

# Wait until we've uploaded a zim file
# kiwix-serve refuses to run if the file doesn't exist.
while [ ! -f /var/data/kiwix.zim ]
do
  sleep 1
done

echo "We see /var/data/kiwix.zim. Starting kiwix.";

export LD_LIBRARY_PATH=/usr/local/lib/x86_64-linux-gnu/:/opt/app/openzim/zimlib/src/.libs/:/opt/app/xapian/xapian-core/.libs/:/opt/app/pugixml/

kiwix-serve --port=8080 /var/data/kiwix.zim
