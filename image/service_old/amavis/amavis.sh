#!/bin/sh

# -e Exit immediately if a command exits with a non-zero status
set -e

LDAP_HOST=${LDAP_HOST}
LDAP_BASE_DN=${LDAP_BASE_DN}
DOMAIN_NAME=${DOMAIN_NAME}

# amavis is not already configured
if [ ! -e /etc/amavis/docker_bootstrapped ]; then

  # Set DOMAIN_NAME
  sed -i "s/mail.example.com/smtp.$DOMAIN_NAME/" /etc/amavis/conf.d/05-node_id

  # Set ldap host
  sed -i "s/127.0.0.1/$LDAP_HOST/" /etc/amavis/conf.d/50-user


  # Set ldap base dn
  sed -i -e "s/dc=example,dc=com/$LDAP_BASE_DN/g" /etc/amavis/conf.d/50-user

  chown amavis -R /usr/lib/perl5/auto/

  touch /etc/amavis/docker_bootstrapped
else
  status "found already-configured amavis"
fi

# exec amavis if spamassasin and clamav are ready
if [ -e /var/run/spamd.pid ] && [ -e /run/clamav/clamd.pid ]; then
  exec /usr/sbin/amavisd-new foreground
else
  sleep 60
fi
