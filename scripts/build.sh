#!/bin/sh

export PATH="$PATH:/build/dev/scripts/builders"
export LIB_PATH=/build/lib/sources
export BASE_DIR=/srv/magma

yum install -y epel-release
yum groupinstall -y 'Development Tools'
yum install -y check-devel ncurses-devel libbsd libbsd-devel valgrind-devel git mysql

if [ ! -d "/build" ]; then
  git clone --depth=1 https://github.com/lavabit/magma.git /build
fi

cd /build
build.lib.sh extract
build.lib.sh prep
build.lib.sh build
build.lib.sh combine
build.lib.sh load
#build.lib.sh check
build.check.sh
build.magma.sh

strip -v /build/magmad /build/magmad.check /build/magmad.so
mkdir -p /srv/magma/bin
mv -v /build/magmad /build/magmad.so /build/magmad.check $BASE_DIR/bin/
mv /build/res $BASE_DIR/
mv /build/web $BASE_DIR/

yum history -y rollback 3
yum install -y mysql gettext
yum clean all

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

#TODO cleanup
rm -rf /build
