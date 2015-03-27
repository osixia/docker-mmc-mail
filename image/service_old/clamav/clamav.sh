#!/bin/sh

# -e Exit immediately if a command exits with a non-zero status
set -e

LDAP_HOST=${LDAP_HOST}
LDAP_BASE_DN=${LDAP_BASE_DN}
DOMAIN_NAME=${DOMAIN_NAME}

# clamav is not already configured
if [ ! -e /etc/clamav/docker_bootstrapped ]; then

  adduser clamav amavis

  freshclam

  sed -i "s/Foreground false/Foreground true/" /etc/clamav/clamd.conf

  mkdir /var/run/clamav
  chown clamav /var/run/clamav/


  touch /etc/clamav/docker_bootstrapped
else
  status "found already-configured clamav"
fi

exec /usr/sbin/clamd start
