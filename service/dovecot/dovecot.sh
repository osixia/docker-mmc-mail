#!/bin/sh

# -e Exit immediately if a command exits with a non-zero status
set -e

LDAP_HOST=${LDAP_HOST}
LDAP_BASE_DN=${LDAP_BASE_DN}

# dovecot is not already configured
if [ ! -e /etc/dovecot/docker_bootstrapped ]; then

  cp /etc/dovecot/config/dovecot.conf /etc/dovecot/dovecot.conf
  cp /etc/dovecot/config/dovecot-ldap.conf.ext /etc/dovecot/dovecot-ldap.conf.ext

  # Set ldap host
  sed -i -e "s/127.0.0.1/$LDAP_HOST/g" /etc/dovecot/dovecot-ldap.conf.ext

  # Set ldap base dn
  sed -i -e "s/dc=example,dc=com/$LDAP_BASE_DN/g" /etc/dovecot/dovecot-ldap.conf.ext


  touch /etc/dovecot/docker_bootstrapped
else
  status "found already-configured dovecot"
fi

exec /usr/sbin/dovecot -F
