#!/bin/bash
set -euo pipefail

# Wait until we've uploaded a zim file
# kiwix-serve refuses to run if the file doesn't exist.
while [ ! -f /var/data/kiwix.zim ]
do
  sleep 1
done

echo "We see /var/data/kiwix.zim. Starting kiwix.";

/kiwix-run/kiwix-serve --nolibrarybutton --port=8080 /var/data/kiwix.zim
