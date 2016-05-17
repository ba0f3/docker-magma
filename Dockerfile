FROM centos:6
MAINTAINER Huy Doan <me@huy.im>

RUN mkdir /magma

VOLUME /magma

WORKDIR /magma

ENV TERM dumb

RUN yum install -y epel-release
RUN yum groupinstall -y 'Development Tools'
RUN yum install -y check-devel ncurses-devel libbsd libbsd-devel valgrind-devel git

COPY scripts /scripts
RUN chmod +x /scripts/*.sh

ENTRYPOINT /scripts/entrypoint.sh
