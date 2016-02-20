#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

# clamav-milter
ln -sf ${CONTAINER_SERVICE_DIR}/clamav-milter/assets/clamav-milter.conf /etc/clamav/clamav-milter.conf

exit 0
