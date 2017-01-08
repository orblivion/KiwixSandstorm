#!/bin/bash
set -euo pipefail
# This script is run in the VM each time you run `vagrant-spk dev`.  This is
# the ideal place to invoke anything which is normally part of your app's build
# process - transforming the code in your repository into the collection of files
# which can actually run the service in production
#
# Some examples:
#
#   * For a C/C++ application, calling
#       ./configure && make && make install
#   * For a Python application, creating a virtualenv and installing
#     app-specific package dependencies:
#       virtualenv /opt/app/env
#       /opt/app/env/bin/pip install -r /opt/app/requirements.txt
#   * Building static assets from .less or .sass, or bundle and minify JS
#   * Collecting various build artifacts or assets into a deployment-ready
#     directory structure

#!/bin/bash

set -euo pipefail
ZIM_UPLOADER=/opt/app/zim_uploader
VENV2=$ZIM_UPLOADER/env
if [ ! -d $VENV2 ] ; then
    virtualenv $VENV2
else
    echo "$VENV2 exists, moving on"
fi
VENV3=/opt/app/env3
if [ ! -d $VENV3 ] ; then
    virtualenv -p python3 $VENV3
else
    echo "$VENV3 exists, moving on"
fi

$VENV2/bin/pip install -r $ZIM_UPLOADER/requirements.txt
# TODO requirements.txt
$VENV3/bin/pip3 install scikit-build==0.5.1
$VENV3/bin/pip3 install meson==0.37.1

# Build kiwix-lib
KIWIXLIBFILE=/usr/local/lib/x86_64-linux-gnu/libkiwix.so

if [ ! -f $KIWIXLIBFILE ]; then
    echo "Buliding kiwix-lib"

    cd /opt/app
    rm -rf kiwix-lib
    git clone https://github.com/kiwix/kiwix-lib
    cd kiwix-lib
    git checkout a3d01b6303c1ddf02a80d18b9283736c5e4f2f1c # alpha, but the only thing that builds on Debian Jesse so far
    mkdir build
    $VENV3/bin/python3 $VENV3/bin/meson build
    cd build
    ninja
    sudo ninja install
    echo "Built kiwix-lib"
else
    echo "Already built kiwix-lib"
fi

# Build kiwix-tools
KIWIXSERVEFILE=/usr/local/bin/kiwix-serve

if [ ! -f $KIWIXSERVEFILE ]; then
    echo "Buliding kiwix-tools"

    cd /opt/app
    rm -rf kiwix-tools
    git clone https://github.com/kiwix/kiwix-tools
    cd kiwix-tools
    git checkout dc6c9d618f5de1fb5a219e531c46956858590ef4 # alpha, not tagged yet
    mkdir build
    $VENV3/bin/python3 $VENV3/bin/meson build
    cd build
    ninja
    sudo ninja install
    echo "Built kiwix-tools"
else
    echo "Already built kiwix-tools"
fi

exit 0
