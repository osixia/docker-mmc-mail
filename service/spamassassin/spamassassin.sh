#!/bin/sh

# -e Exit immediately if a command exits with a non-zero status
set -e

# dovecot is not already configured
if [ ! -e /etc/spamassassin/docker_bootstrapped ]; then

  sed -i "s/CRON=0/CRON=1/" /etc/default/spamassassin

  sa-update

  exec /sbin/setuser amavis razor-admin -d --create 
  exec /sbin/setuser amavis razor-admin -register
  exec /sbin/setuser amavis razor-admin -discover

  exec /sbin/setuser amavis pyzor discover
  
  sed -i "s/\$sa_spam_subject_tag/#\$sa_spam_subject_tag/" /etc/default/spamassassin

  touch /etc/spamassassin/docker_bootstrapped
else
  status "found already-configured dovecot"
fi

# exec /usr/sbin/dovecot -F
