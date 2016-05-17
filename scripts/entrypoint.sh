#!/bin/sh

export PATH="$PATH:$HOME/bin"

build() {
    git clone --depth=1 https://github.com/lavabit/magma.git /build
    cd /build
    /build/scripts/linkup.sh

    build.lib all
    build.check
    build.magma
    #freshen.clamav
    strip magmad magmad.check magmad.so
    cp -r magmad magmad.check magmad.so res web /magma

}

init() {
    /script/install.sh $MYSQL_HOST $MYSQL_USER $MYSQL_PASSWORD $MYSQL_SCHEMA
}

run() {
    /magma/magmad
}

case "$1" in
    build) build
    ;;
    init) init
    ;;
    *)
	run()
    ;;
esac
