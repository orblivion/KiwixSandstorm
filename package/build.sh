#!/bin/bash
set -euo pipefail

KIWIX_DIR=kiwix-run
EXTRACTED_DIR=kiwix-tools_linux-x86_64-3.0.1
DEPENDENCIES=dependencies
DOWNLOAD_FILE=${EXTRACTED_DIR}.tar.gz

rm -fr $EXTRACTED_DIR
rm -f $DOWNLOAD_FILE

if [ ! -f $KIWIX_DIR/kiwix-serve ]; then
    printf "\n\n\nDownloading Kiwix-Tools\n"
    wget https://download.kiwix.org/release/kiwix-tools/${DOWNLOAD_FILE}
    sha256sum -c SHA256SUM
    tar xf ${DOWNLOAD_FILE}

    printf "\n\n\nPutting Kiwix-Serve into the kiwix-run directory\n"
    mv $EXTRACTED_DIR/kiwix-serve $KIWIX_DIR
else
    printf "\n\n\nAlready installed Kiwix-Serve\n"
fi

printf "\n\n\nInstalling nginx\n"
sudo apt-get install -y nginx

printf "\n\n\nInstalling dependencies for uploader\n"
sudo apt-get install -y nginx uwsgi uwsgi-plugin-python3 python3-flask

printf "\n\n\nStopping global nginx\n"
sudo service nginx stop
sudo systemctl disable nginx

DEPENDENCIESFILE=$DEPENDENCIES/DEPENDENCIES_DONE
if [ ! -f $DEPENDENCIESFILE ]; then
    cd $DEPENDENCIES

    printf "\n\n\nGetting jquery file uploader assets\n"
    rm -rf jQuery-File-Upload
    git clone https://github.com/blueimp/jQuery-File-Upload
    git -C jQuery-File-Upload checkout 0b4af3c57b86b3c7147c4d7c75deb71a0133f0e3 # tag v9.18.0

    printf "\n\n\nGetting bootstrap repo for glyphicons-halflings-regular.* and bootstrap.min.js\n"
    git clone https://github.com/twbs/bootstrap-sass
    git -C bootstrap-sass checkout 5d6b2ebba0c2a5885ce2f0e01e9218db3d3b5e47 # tag v3.3.7

    printf "\n\n\nGetting Bootstrap css. (Not built in the repos)\n"
    rm -f bootstrap.min.css
    wget https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css
    cat bootstrap.min.css | sha256sum | grep f75e846cc83bd11432f4b1e21a45f31bc85283d11d372f7b19accd1bf6a2635c

    printf "\n\n\nGetting jquery assets\n"
    rm -f jquery-3.2.0.min.js
    wget https://code.jquery.com/jquery-3.2.0.min.js
    cat jquery-3.2.0.min.js | sha256sum | grep 2405bdf4c255a4904671bcc4b97938033d39b3f5f20dd068985a8d94cde273e2

    cd -
    touch $DEPENDENCIESFILE
    printf "\n\n\nInstalled dependencies for uploader\n"
else
    printf "\n\n\nAlready installed dependencies for uploader\n"
fi
