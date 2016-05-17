#!/bin/sh

export PATH="$PATH:/srv/magma/bin"
run() {
    /scripts/install.sh $MYSQL_HOST $MYSQL_USER $MYSQL_PASSWORD $MYSQL_SCHEMA
    magmad /magma/magma.config
}

$*
