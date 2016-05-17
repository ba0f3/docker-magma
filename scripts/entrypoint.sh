#!/bin/sh

export BIN_DIR=/bin
export LIB_DIR=/lib64
export PATH="$PATH:/magma/bin"

build() {
    yum install -y epel-release
    yum groupinstall -y 'Development Tools'
    yum install -y check-devel ncurses-devel libbsd libbsd-devel valgrind-devel git mysql
    #git clone --depth=1 https://github.com/lavabit/magma.git /build
    cd /build
    /build/dev/scripts/builders/build.lib.sh extract
    /build/dev/scripts/builders/build.lib.sh prep
    /build/dev/scripts/builders/build.lib.sh build
    /build/dev/scripts/builders/build.lib.sh combine
    /build/dev/scripts/builders/build.lib.sh load

    #./dev/scripts/builders/build.lib.sh check
    /build/dev/scripts/builders/build.check.sh
    /build/dev/scripts/builders/build.magma.sh

    strip -v magmad magmad.check magmad.so
    mkdir -v /magma/bin
    cp -v magmad magmad.check magmad.so /magma/bin
    cp -rv res web /magma

    cp -v lib/sources/zlib/libz.so.* $LIB_DIR/
    cp -v lib/sources/openssl/libssl.so.* $LIB_DIR/
    cp -v lib/sources/openssl/libcrypto.so.* $LIB_DIR/
    cp -v lib/sources/clamav/libclamav/.libs/libclamav.so.* $LIB_DIR/
    cp -v lib/sources/clamav/freshclam/.libs/freshclam $BIN_DIR/

    yum history rollback 3
    yum install mysql
    #rm -rf /build
    #TODO cleanup
}

init() {
    /scripts/install.sh $MYSQL_HOST $MYSQL_USER $MYSQL_PASSWORD $MYSQL_SCHEMA
}

run() {
    magmad /magma/etc/magma.config
}

$*
