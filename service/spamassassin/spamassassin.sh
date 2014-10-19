#!/bin/sh

# -e Exit immediately if a command exits with a non-zero status
set -e

# spamassasin is not already configured
if [ ! -e /etc/spamassassin/docker_bootstrapped ]; then

  sed -i "s/CRON=0/CRON=1/" /etc/default/spamassassin
  sed -i "s/\$sa_spam_subject_tag/#\$sa_spam_subject_tag/" /etc/default/spamassassin

  echo "00 20   * * 6   root    /etc/spamassassin/assets/learn-spam.sh > /var/log/learn-spam.log 2> /var/log/learn-spam.err" >> /etc/cron.d/amavisd-new

  sa-update

  /sbin/setuser amavis razor-admin -d --create 
  /sbin/setuser amavis razor-admin -register
  /sbin/setuser amavis razor-admin -discover

  /sbin/setuser amavis pyzor discover
  
  touch /etc/spamassassin/docker_bootstrapped
else
  status "found already-configured spamassasin"
fi

exec /usr/sbin/spamd -d
