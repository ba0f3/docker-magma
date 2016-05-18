#!/bin/sh

export PATH="$PATH:/srv/magma/bin"
if [ "$BASE_DIR" = "" ]; then
    export BASE_DIR=/magma
fi

run() {
    if [ -f "/scripts/install.sh" ]; then
	/scripts/install.sh $MYSQL_HOST $MYSQL_USER $MYSQL_PASSWORD $MYSQL_SCHEMA
	rm -f /scripts/install.sh
    fi
    magmad $BASE_DIR/etc/magma.config
}

update() {
    freshclam --user=root --datadir=$BASE_DIR/res/virus --config-file=$BASE_DIR/etc/freshclam.conf
}

$@
