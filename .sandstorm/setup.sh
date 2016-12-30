#!/bin/bash

# When you change this file, you must take manual action. Read this doc:
# - https://docs.sandstorm.io/en/latest/vagrant-spk/customizing/#setupsh

set -euo pipefail
# This is the ideal place to do things like:
#
#    export DEBIAN_FRONTEND=noninteractive
#    apt-get update
#    apt-get install -y nginx nodejs nodejs-legacy python2.7 mysql-server
#
# If the packages you're installing here need some configuration adjustments,
# this is also a good place to do that:
#
#    sed --in-place='' \
#            --expression 's/^user www-data/#user www-data/' \
#            --expression 's#^pid /run/nginx.pid#pid /var/run/nginx.pid#' \
#            --expression 's/^\s*error_log.*/error_log stderr;/' \
#            --expression 's/^\s*access_log.*/access_log off;/' \
#            /etc/nginx/nginx.conf

# By default, this script does nothing.  You'll have to modify it as
# appropriate for your application.

cd /opt/app

# NOTE: This sha256 didn't come from Kiwix themselves. See `README.md` for details.
KIWIXSHA=2861c1ec49f99eace6543871258614e75e46f486d40b2f61b212dd13708f731e
KIWIXPKGFILE=kiwix-linux-x86_64.tar.bz2
KIWIXPKGTMPFILE=kiwix-linux-x86_64.tar.bz2.tmp

if [ ! -f $KIWIXPKGFILE ]; then
    echo "Downloading kiwix"
    wget -q "http://download.kiwix.org/bin/kiwix-linux-x86_64.tar.bz2" -O $KIWIXPKGTMPFILE
    echo "Got Kiwix binaries"
    if (sha256sum $KIWIXPKGTMPFILE | grep $KIWIXSHA > /dev/null)
    then
        mv $KIWIXPKGTMPFILE $KIWIXPKGFILE
        echo "Verified Kiwix binaries"
    else
        >&2 echo "ERROR: Failed to verify Kiwix binaries"
        exit 1
    fi
else
    echo "Already have Kiwix binaries"
fi

echo "Extracting kiwix"
tar xjf $KIWIXPKGFILE

echo "Installing nginx"
sudo apt-get install -y nginx

exit 0
