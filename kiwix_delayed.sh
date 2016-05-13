#!/bin/bash
set -euo pipefail

# Wait until we've uploaded a zim file
# kiwix-serve refuses to run if the file doesn't exist.
while [ ! -f /var/kiwix.zim ]
do
  sleep 1
done

echo "We see /var/kiwix.zim. Starting kiwix.";

kiwix/bin/kiwix-serve --port=8080 /var/kiwix.zim
