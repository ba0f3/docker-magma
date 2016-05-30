#!/bin/bash
# This script is targeting CentOS release 6.5

readonly PROGNAME=$(basename $0)
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


if [ "$BASE_DIR" = "" ]; then
    export BASE_DIR=/magma
fi

if [ "$DOMAIN" = "" ];then
    export DOMAIN="localhost.localdomain"
fi

echo "Setting up server for domain ${DOMAIN} on ${BASE_DIR}"


echo "Generating random secrets..."
export SALT=`echo "$(dd if=/dev/urandom bs=33 count=1 | base64 --wrap=300)"`
export SESSION=`echo "$(dd if=/dev/urandom bs=33 count=1 | base64 --wrap=300)"`

echo "Making directory structures.."
mkdir -p "${BASE_DIR}/etc/"
mkdir -p "${BASE_DIR}/logs/"
mkdir -p "${BASE_DIR}/spool/"
mkdir -p "${BASE_DIR}/storage/tanks/"
mkdir -p "${BASE_DIR}/servers/local/"
mkdir -p "${BASE_DIR}/res/virus/"

echo "Coping resources..."
cp -r /srv/magma/res $BASE_DIR/


echo "Generating self-signed certificated for domain ${DOMAIN}"
openssl req -x509 -nodes -days 3650 -subj "/C=CA/ST=QC/L=Montreal/O=Company Name/CN=${DOMAIN}" -newkey rsa:4096 -keyout $BASE_DIR/etc/key.pem -out $BASE_DIR/etc/$DOMAIN.pem
cat $BASE_DIR/etc/key.pem >> $BASE_DIR/etc/$DOMAIN.pem
chmod -v o-rwx $BASE_DIR/etc/$DOMAIN.pem

perl /srv/magma/bin/opendkim-genkey --verbose --domain=$DOMAIN --selector=magma --directory=$BASE_DIR/etc --bits=4096
mv -v $BASE_DIR/etc/magma.private $BASE_DIR/etc/dkim.$DOMAIN.pem
mv -v $BASE_DIR/etc/magma.txt $BASE_DIR/etc/dkim.$DOMAIN.txt
cat $BASE_DIR/etc/dkim.$DOMAIN.txt


echo "Building magma.config"
if [ ! -e /scripts/magma.config.stub ]; then
	echo "Can't find magma.config.stub file"
	exit 1
fi
# Substitute the placeholders in magma.config.stub with user input
envsubst < /scripts/magma.config.stub > $BASE_DIR/etc/magma.config


echo "Initializing default database"
/scripts/schema.init.sh $MYSQL_HOST $MYSQL_USER $MYSQL_PASSWORD $MYSQL_SCHEMA

echo "Downloading ClamAV virus definitions"
mkdir -p $BASE_DIR/res/virus
printf "Bytecode yes\nSafeBrowsing yes\nCompressLocalDatabase no\nDatabaseMirror database.clamav.net\n" > $BASE_DIR/etc/freshclam.conf
/srv/magma/bin/freshclam --user=root --datadir=$BASE_DIR/res/virus --config-file=$BASE_DIR/etc/freshclam.conf
echo "*** INSTALLATION COMPLETED ***"
