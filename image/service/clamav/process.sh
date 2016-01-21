#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

ln -sf ${CONTAINER_SERVICE_DIR}/clamav/assets/cronjobs /etc/cron.d/clamav
chmod 600 ${CONTAINER_SERVICE_DIR}/clamav/assets/cronjobs

exec /usr/sbin/clamd
