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

DEPENDENCIES=/opt/app/dependencies
VENV3=/opt/app/env3
if [ ! -d $VENV3 ] ; then
    virtualenv -p python3 $VENV3
else
    echo "$VENV3 exists, moving on"
fi

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

ZIM_UPLOADER=/opt/app/zim_uploader

# Set up uploader
FLASKFILEUPLOADERFILE=$ZIM_UPLOADER/env/lib/python2.7/site-packages/flask/app.py
if [ ! -f $FLASKFILEUPLOADERFILE ]; then
    cd $DEPENDENCIES

    echo "Getting jquery file uploader assets"
    rm -rf jQuery-File-Upload
    git clone https://github.com/blueimp/jQuery-File-Upload
    git -C jQuery-File-Upload checkout 0b4af3c57b86b3c7147c4d7c75deb71a0133f0e3 # tag v9.18.0

    echo "Getting JavaScript-Templates assets"
    rm -rf JavaScript-Templates
    git clone https://github.com/blueimp/JavaScript-Templates
    git -C JavaScript-Templates checkout dc7631396cd541db5644aa2c651e342c68511aad # tag v3.8.0

    echo "Getting bootstrap repo for glyphicons-halflings-regular.* and bootstrap.min.js"
    git clone https://github.com/twbs/bootstrap-sass
    git -C bootstrap-sass checkout 5d6b2ebba0c2a5885ce2f0e01e9218db3d3b5e47 # tag v3.3.7

    echo "Getting Bootstrap css. (Not built in the repos)"
    rm -f bootstrap.min.css
    wget https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css
    cat bootstrap.min.css | sha256sum | grep f75e846cc83bd11432f4b1e21a45f31bc85283d11d372f7b19accd1bf6a2635c

    echo "Getting jquery assets"
    rm -f jquery-3.2.0.min.js
    wget https://code.jquery.com/jquery-3.2.0.min.js
    cat jquery-3.2.0.min.js | sha256sum | grep 2405bdf4c255a4904671bcc4b97938033d39b3f5f20dd068985a8d94cde273e2

    echo "Installing dependencies for uploader"
    cd $ZIM_UPLOADER
    virtualenv env
    env/bin/pip install -r uploader/requirements.txt

    echo "Installed dependencies for uploader"
else
    echo "Already installed dependencies for uploader"
fi


exit 0
