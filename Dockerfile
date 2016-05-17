FROM centos:6
MAINTAINER Huy Doan <me@huy.im>

RUN mkdir /magma
VOLUME /magma
WORKDIR /magma

ENV TERM dumb

RUN yum install -y epel-release
RUN yum groupinstall -y 'Development Tools'
RUN yum install -y check-devel ncurses-devel libbsd libbsd-devel valgrind-devel git mysql

COPY src /build
#RUN git clone --depth=1 https://github.com/lavabit/magma.git /build
RUN cd /build
RUN /build/dev/scripts/builders/build.lib.sh extract
RUN /build/dev/scripts/builders/build.lib.sh prep
RUN /build/dev/scripts/builders/build.lib.sh build
RUN /build/dev/scripts/builders/build.lib.sh combine
RUN /build/dev/scripts/builders/build.lib.sh load

#RUN /build/dev/scripts/builders/build.lib.sh check
RUN /build/dev/scripts/builders/build.check.sh
RUN /build/dev/scripts/builders/build.magma.sh

RUN strip -v magmad magmad.check magmad.so
RUN mkdir -pv /magma/bin
RUN cp -v magmad magmad.check magmad.so /magma/bin
RUN cp -rv res web /magma

RUN cp -v lib/sources/zlib/libz.so.* /lib64/
RUN cp -v lib/sources/openssl/libssl.so.* /lib64/
RUN cp -v lib/sources/openssl/libcrypto.so.* /lib64/
RUN cp -v lib/sources/clamav/libclamav/.libs/libclamav.so.* /lib64/
RUN cp -v lib/sources/clamav/freshclam/.libs/freshclam /magma/bin/

RUN yum history rollback 3
RUN yum install mysql
#TODO cleanup
#RUN rm -vrf /build

COPY scripts /scripts
RUN chmod +vx /scripts/*.sh
COPY magma.config.stub /tmp/

ENTRYPOINT ["/scripts/entrypoint.sh"]
CMD ["run"]
