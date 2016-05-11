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

if [ ! -f kiwix-linux-x86_64.tar.bz2 ]; then
    echo "Downloading kiwix"
    wget -q "http://download.kiwix.org/bin/kiwix-linux-x86_64.tar.bz2"
else
    echo "Already have Kiwix binaries"
fi

echo "Extracting kiwix"
tar xjf kiwix-linux-x86_64.tar.bz2

cd /opt/app/sample_zim/

if [ ! -f icd10_fr_all_2012-01.zim ]; then
    echo "Downloading sample zim file"
    wget -q "http://download.kiwix.org/zim/other/icd10_fr_all_2012-01.zim"
else
    echo "Already have sample zim file"
fi

sudo apt-get install -y nginx

exit 0
