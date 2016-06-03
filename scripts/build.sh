#!/bin/sh

export PATH="$PATH:/build/dev/scripts/builders"
export LIB_PATH=/build/lib/sources
export BASE_DIR=/srv/magma

yum install -q -y epel-release
yum install -q -y patch autoconf automake libtool gcc-c++ check-devel ncurses-devel libbsd libbsd-devel valgrind-devel git mysql gettext haveged
yum clean all

if [ ! -d "/build" ]; then
    git clone --depth=1 https://github.com/rgv151/magma.git /build
else
    cd /build
    git pull
fi

mkdir -p $BASE_DIR/bin

if [ ! -d "$BASE_DIR/res" ]; then
   mv /build/res $BASE_DIR/
fi

cd /build

LOCK_FILE=/build/lib.lock
if [ ! -f "$LOCK_FILE" ]; then
    build.lib.sh extract
    build.lib.sh prep

    touch $LOCK_FILE
fi

build.lib.sh build
build.lib.sh combine
build.lib.sh load
#build.lib.sh check

build.check.sh
build.magma.sh

strip -v /build/magmad /build/magmad.check /build/magmad.so
mv -v /build/magmad /build/magmad.so /build/magmad.check $BASE_DIR/bin/

cp -v $LIB_PATH/zlib/libz.so.* /lib64/
cp -v $LIB_PATH/openssl/libssl.so.* /lib64/
cp -v $LIB_PATH/openssl/libcrypto.so.* /lib64/
cp -v $LIB_PATH/clamav/libclamav/.libs/libclamav.so.* /lib64/
cp -v $LIB_PATH/clamav/libclamav/.libs/libclamunrar_iface.so /lib64/
cp -v $LIB_PATH/clamav/libclamav/.libs/libclamunrar_iface.a /lib64/
cp -v $LIB_PATH/clamav/libclamav/.libs/libclamunrar.so* /lib64/
cp -v $LIB_PATH/clamav/libclamav/.libs/libclamunrar.a /lib64/
cp -v $LIB_PATH/clamav/freshclam/.libs/freshclam $BASE_DIR/bin/
cp -v $LIB_PATH/dkim/opendkim/opendkim-genkey $BASE_DIR/bin/
