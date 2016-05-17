FROM centos:6
MAINTAINER Huy Doan <me@huy.im>

RUN mkdir /magma
VOLUME /magma
WORKDIR /magma

ENV TERM dumb

RUN yum install -y epel-release
RUN yum groupinstall -y 'Development Tools'
RUN yum install -y check-devel ncurses-devel libbsd libbsd-devel valgrind-devel git mysql

#COPY src /build
RUN git clone --depth=1 https://github.com/lavabit/magma.git /build
RUN cd /build
RUN /build/dev/scripts/builders/build.lib.sh extract
RUN /build/dev/scripts/builders/build.lib.sh prep
RUN /build/dev/scripts/builders/build.lib.sh build
RUN /build/dev/scripts/builders/build.lib.sh combine
RUN /build/dev/scripts/builders/build.lib.sh load

#RUN /build/dev/scripts/builders/build.lib.sh check
RUN /build/dev/scripts/builders/build.check.sh
RUN /build/dev/scripts/builders/build.magma.sh

RUN strip -v /build/magmad /build/magmad.check /build/magmad.so
RUN mkdir -p /srv/magma/bin
RUN mv -v /build/magmad /build/magmad.so /build/magmad.check /srv/magma/bin/
RUN mv -v /build/res /srv/magma/
RUN mv -v /build/web /srv/magma/

RUN yum history -y rollback 3
RUN yum install -y mysql gettext

RUN cp -v /build/lib/sources/zlib/libz.so.* /lib64/
RUN cp -v /build/lib/sources/openssl/libssl.so.* /lib64/
RUN cp -v /build/lib/sources/openssl/libcrypto.so.* /lib64/
RUN cp -v /build/lib/sources/clamav/libclamav/.libs/libclamav.so.* /lib64/
RUN cp -v /build/lib/sources/clamav/libclamav/.libs/libclamunrar_iface.so /lib64/ && ln -s /lib64/libclamunrar_iface.so /usr/local/lib64/libclamunrar_iface.so.6.1.23
RUN cp -v /build/lib/sources/clamav/libclamav/.libs/libclamunrar_iface.a /lib64 && ln -s /lib64/libclamunrar_iface.a /usr/local/lib64/libclamunrar_iface.a
RUN cp -v /build/lib/sources/clamav/libclamav/.libs/libclamunrar.so* /lib64/ && ln -s /lib64/libclamunrar.so /usr/local/lib64/libclamunrar.so.6
RUN cp -v /build/lib/sources/clamav/libclamav/.libs/libclamunrar.a /lib64/ && ln -s /lib64/libclamunrar.so /usr/local/lib64/libclamunrar.a
RUN cp -v /build/lib/sources/clamav/freshclam/.libs/freshclam /srv/magma/bin/
RUN cp -v /build/lib/sources/dkim/opendkim/opendkim-genkey /srv/magma/bin/
COPY magma.config.stub /tmp/
COPY limits.conf /etc/security/limits.conf
COPY scripts /scripts
RUN chmod -v +x /scripts/*.sh

#TODO cleanup
RUN rm -rf /build

EXPOSE 25 465 110 995 143 995 10000 10500

CMD ["/scripts/entrypoint.sh"]
