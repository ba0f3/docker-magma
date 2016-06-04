#!/bin/sh


export PATH="$PATH:/srv/magma/bin"
if [ "$BASE_DIR" = "" ]; then
    export BASE_DIR=/magma
fi

LOCK_FILE="$BASE_DIR/install.lock"


run() {
    /sbin/service haveged start
    if [ ! -f "$LOCK_FILE" ]; then
	/scripts/install.sh $MYSQL_HOST $MYSQL_USER $MYSQL_PASSWORD $MYSQL_SCHEMA
	touch $LOCK_FILE
    else
	HOSTNAME=$(hostname)
	mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD -e  "UPDATE Hosts SET hostname = '$HOSTNAME' WHERE hostnum = 1;" $MYSQL_SCHEMA
    fi
    magmad $BASE_DIR/etc/magma.config
}

$@
