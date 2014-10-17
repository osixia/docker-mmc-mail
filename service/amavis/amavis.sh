#!/bin/sh

# -e Exit immediately if a command exits with a non-zero status
set -e

LDAP_HOST=${LDAP_HOST}
LDAP_BASE_DN=${LDAP_BASE_DN}
HOSTNAME=${HOSTNAME}

# dovecot is not already configured
if [ ! -e /etc/amavis/docker_bootstrapped ]; then

  adduser clamav amavis

  cp  /etc/amavis/config/* /etc/amavis/conf.d/

  # Set hostname
  sed -i "s/mail.example.com/$HOSTNAME/" /etc/amavis/conf.d/05-node_id

  # Set ldap host
  sed -i "s/127.0.0.1/$LDAP_HOST/" /etc/amavis/conf.d/50-user


  # Set ldap base dn
  sed -i -e "s/dc=example,dc=com/$LDAP_BASE_DN/g" /etc/amavis/conf.d/50-user

  touch /etc/amavis/docker_bootstrapped
else
  status "found already-configured dovecot"
fi

