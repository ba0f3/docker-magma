#!/bin/sh

export PATH="$PATH:/srv/magma/bin"
if [ "$BASE_DIR" = "" ]; then
    export BASE_DIR=/magma
fi

freshclam --user=root --datadir=$BASE_DIR/res/virus --config-file=$BASE_DIR/etc/freshclam.conf
