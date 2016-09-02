#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

ln -sf ${CONTAINER_SERVICE_DIR}/opendmarc/assets/config/opendmarc.conf /etc/opendmarc.conf
chown opendmarc:opendmarc /etc/opendmarc.conf

exit 0
