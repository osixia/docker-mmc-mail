#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

[[ ! -d /var/mail/sieve/ ]] && mkdir -p /var/mail/sieve/
ln -fs ${CONTAINER_SERVICE_DIR}/sieve/assets/default.sieve /var/mail/sieve/default.sieve
chown -R vmail:vmail /var/mail/sieve

sievec /var/mail/sieve/default.sieve

exit 0
