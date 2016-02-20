#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

sv start /container/run/process/clamav || exit 1

sleep 30

exec /usr/sbin/clamav-milter
