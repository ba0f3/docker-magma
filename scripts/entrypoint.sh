#!/bin/sh


export PATH="$PATH:/srv/magma/bin"
if [ "$BASE_DIR" = "" ]; then
    export BASE_DIR=/magma
fi

LOCK_FILE="$BASE_DIR/install.lock"


run() {
    if [ -f "$LOCK_FILE" ]; then
	/scripts/install.sh $MYSQL_HOST $MYSQL_USER $MYSQL_PASSWORD $MYSQL_SCHEMA
	touch $LOCK_FILE
    fi
    magmad $BASE_DIR/etc/magma.config
}

$@
