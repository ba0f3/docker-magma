#!/bin/sh

export PATH="$PATH:/srv/magma/bin"

if [ -f "/scripts/install.sh" ]; then
  /scripts/install.sh $MYSQL_HOST $MYSQL_USER $MYSQL_PASSWORD $MYSQL_SCHEMA
  rm -f /scripts/install.sh
fi
magmad /magma/etc/magma.config
