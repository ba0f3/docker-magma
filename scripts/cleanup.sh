#!/bin/sh

rm -rf /build
yum history -y rollback 3
