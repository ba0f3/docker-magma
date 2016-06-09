#!/bin/sh

export PATH="$PATH:/build/dev/scripts/builders:/build/cmake/bin"
export LIB_PATH=/build/lib/sources
export BASE_DIR=/srv/magma

apk add --update bash patch autoconf automake libtool gcc check-dev ncurses ncurses-dev libbsd libbsd-dev valgrind-dev git

#if [ ! -f "/build/cmake/bin/cmake" ]
#   curl https://cmake.org/files/v3.6/cmake-3.6.0-rc1-Linux-x86_64.tar.gz > /tmp/cmake.tar.gz
#   tar xzf /tmp/cmake.gz -C /build
#fi


if [ ! -d "/build" ]; then
    git clone --depth=1 https://github.com/rgv151/magma.git /build
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
cp -c $LIB_PATH/dkim/opendkim/opendkim-genzone $BASE_DIR/bin/
cp -c $LIB_PATH/dkim/opendkim/opendkim-testkey $BASE_DIR/bin/

chmod -v +x $BASE_DIR/bin/*

apk del patch autoconf automake libtool gcc check-dev ncurses-dev libbsd libbsd-dev valgrind-dev git
apk add --pdate mysql gettext haveged
rm -rf /var/cache/apk/*

rm -rf /build
