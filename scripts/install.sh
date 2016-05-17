#!/bin/bash
# This script is targeting CentOS release 6.5

readonly PROGNAME=$(basename $0)

export BASE_DIR=/srv/magma
export MYSQL_HOST="localhost"
# Usage
usage () {
	cat <<- EOF
	Usage: $PROGNAME [-h <mysql_host>] -u <mysql_user> -p <mysql_password> -s <mysql_schema>

	Installs Magma Classic to the provided directory

	OPTIONS:
	  -h        mysql host
	  -u        mysql user
	  -p        mysql password
	  -s        mysql schema

	Example: $PROGNAME -u magma -p volcano -s Lavabit

	EOF
}



# Process user input
while getopts ":h:u:p:s:" opt; do
    case $opt in
        h)
            export MYSQL_HOST="$OPTARG"
            ;;
        u)
            export MYSQL_USER="$OPTARG"
            ;;
        p)
            export MYSQL_PASSWORD="$OPTARG"
            ;;
        s)
            export MYSQL_SCHEMA="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument" >&2
            exit 1
            ;;
    esac
done


if [ -z "$MYSQL_HOST" \
	-o -z "$MYSQL_USER" \
	-o -z "$MYSQL_PASSWORD" \
	-o -z "$MYSQL_SCHEMA" ]; then
	usage
	echo "None of the user input is optional"
	exit 1
fi

export SALT=`echo "$(dd if=/dev/urandom bs=33 count=1 | base64 --wrap=300)"`
export SESSION=`echo "$(dd if=/dev/urandom bs=33 count=1 | base64 --wrap=300)"`


# Check limits.conf for our entry
grep "*                hard    memlock         1024" /etc/security/limits.conf

if [ $? -ne 0 ]; then
	printf "*                hard    memlock         1024\n*                soft    memlock         2048" >> /etc/security/limits.conf
fi


# Generate expected directories
if [ ! -d "$BASE_DIR" ]; then
    	mkdir -p "${BASE_DIR}/etc/"
	mkdir -p "${BASE_DIR}/logs/"
	mkdir -p "${BASE_DIR}/spool/"
	mkdir -p "${BASE_DIR}/storage/"
	mkdir -p "${BASE_DIR}/servers/local/"
fi

# Build magma.config
if [ ! -e /tmp/magma.config.stub ]; then
	echo "Can't find magma.config.stub file"
	exit 1
fi

if [ "$DOMAIN" = "" ];then
    export DOMAIN="localhost.localdomain"
fi

openssl req -x509 -nodes -days 3650 -subj '/C=CA/ST=QC/L=Montreal/O=Company Name/CN=${DOMAIN}' -newkey rsa:1024 -keyout $BASE_DIR/etc/key.pem -out $BASE_DIR/etc/$DOMAIN.pem


# Substitute the placeholders in magma.config.stub with user input
envsubst < /tmp/magma.config.stub > $BASE_DIR/etc/magma.config

# Reset database to factory defaults
/scripts/schema.init.sh $MYSQL_HOST $MYSQL_USER $MYSQL_PASSWORD $MYSQL_SCHEMA


mkdir -p $BASE_DIR/res/virus
printf "Bytecode yes\nSafeBrowsing yes\nCompressLocalDatabase no\nDatabaseMirror database.clamav.net\n" > $BASE_DIR/res/config/freshclam.conf
$BASE_DIR/bin/freshclam --datadir=$BASE_DIR/res/virus --config-file=$BASE_DIR/res/config/freshclam.conf
