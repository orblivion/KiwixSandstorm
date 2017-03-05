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

echo "apt-get update"
# So we get the latest and greatest of the packages we explicitly want to install.
# I don't do apt-get upgrade because it requires interaction. If I force it to skip
# user input, it seems to uninstall things or something, because things start to
# fail down the line. I guess we have to wait for newer debian images from sandstorm
apt-get update

echo "Installing nginx"
apt-get install -y nginx

echo "Installing build tools"
apt-get install -y git build-essential libtool autoconf pkg-config cmake libicu-dev libctpp2-dev

echo "Installing python stuff"
apt-get install -y python-virtualenv python3 uwsgi uwsgi-plugin-python

echo "Installing libzim requirements"
apt-get install -y git liblzma-dev libicu-dev

echo "Installing libxapian requirements"
apt-get install -y uuid-dev graphviz doxygen help2man tclsh

echo "Installing other kiwix-lib requirements"
apt-get install -y aria2 libctpp2-dev

echo "Installing other kiwix-tools requirements"
apt-get install -y libmicrohttpd-dev

echo "Installing uploader requirements"
apt-get install -y python-dev

# Build libzim - we need a version with pkg-config stuff
LIBZIMFILE=/usr/local/lib/libzim.la
if [ ! -f $LIBZIMFILE ]; then
    echo "Buliding and installing libzim"

    cd /opt/app
    rm -rf openzim
    git clone https://gerrit.wikimedia.org/r/p/openzim.git
    cd /opt/app/openzim
    git checkout b7e5564423b8644cc6405badaee8b8c25ab382b8 # Until they make a release with this change.
    cd zimlib
    ./autogen.sh
    ./configure
    make
    make install
    pkg-config --modversion libzim
    echo "Built and installed libzim"
else
    echo "Already built libzim"
fi

# Build pubixml - we need a version with pkg-config stuff
PUGIXMLFILE=/usr/local/lib/pugixml-1.8/libpugixml.so
if [ ! -f $PUGIXMLFILE ]; then
    echo "Buliding pugixml"

    cd /opt/app
    rm -rf pugixml
    git clone "https://github.com/zeux/pugixml"
    cd /opt/app/pugixml
    git checkout d2deb420bc70369faa12785df2b5dd4d390e523d # v1.8.1

    cmake -DBUILD_PKGCONFIG=1 -DBUILD_SHARED_LIBS=1
    make install

    pkg-config --modversion pugixml

    echo "Built and installed pugixml"
else
    echo "Already built pugixml"
fi

# Build xapian - we need a version with pkg-config stuff
XAPIANCOREFILE=/opt/app/xapian/XAPIAN_DONE
if [ ! -f $XAPIANCOREFILE ]; then
    echo "Buliding and installing xapian-core"

    cd /opt/app
    rm -rf xapian
    git clone https://git.xapian.org/xapian xapian
    cd /opt/app/xapian/xapian-core
    git checkout 3c341a7b671797c32da06fcb1f9ae77521a5819d # v1.4.3

    echo "xapian libtoolize"
    libtoolize

    echo "xapian aclocal"
    aclocal

    echo "xapian autoheader"
    autoheader

    echo "xapian ./preautoreconf"
    ./preautoreconf

    echo "xapian autoconf"
    autoconf

    echo "xapian automake --add-missing"
    automake --add-missing

    echo "xapian ./configure"
    ./configure --enable-maintainer-mode

    echo "xapian make"
    make

    echo "xapian make install"
    make install

    pkg-config --modversion xapian-core

    # Not sure what else to test for. The .so files this installs also seems to
    # be created by the apt commands above, or something. So we're making our
    # own "done" signal here.
    touch $XAPIANCOREFILE

    echo "Built and installed xapian"
else
    echo "Already built xapian"
fi

# Build ninja - we need a version with pkg-config stuff
NINJAFILE=/usr/local/bin/ninja
if [ ! -f $NINJAFILE ]; then
    echo "Buliding and installing ninja-build"

    cd /opt/app
    rm -rf ninja
    git clone https://github.com/ninja-build/ninja.git
    cd /opt/app/ninja
    git checkout 717b7b4a31db6027207588c0fb89c3ead384747b

    ./configure.py --bootstrap
    cp ninja /usr/local/bin/

    echo "Built and installed ninja"
else
    echo "Already built ninja"
fi

service nginx stop
systemctl disable nginx

exit 0
