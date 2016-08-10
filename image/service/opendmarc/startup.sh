#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

ln -sf ${CONTAINER_SERVICE_DIR}/opendkim/assets/config/opendmarc.conf /etc/opendmarc.conf

mkdir -p /var/spool/postfix/opendmarc
chown opendmarc: /var/spool/postfix/opendmarc
usermod -aG opendmarc postfix

exit 0
