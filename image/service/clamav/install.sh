#!/bin/bash -e
# this script is run during the image build

# clamav
mkdir -p /var/run/clamav/
chown clamav /var/run/clamav/

#sed -i --follow-symlinks "s|db.local.clamav.net|db.fr.clamav.net|g" /etc/clamav/freshclam.conf

mkdir /var/spool/postfix/clamav
chown clamav /var/spool/postfix/clamav

sed -i --follow-symlinks "s|Foreground false|Foreground true|g" /etc/clamav/clamd.conf

ln -s /container/service/clamav/assets/cronjobs /etc/cron.d/clamav
chmod 600 /container/service/clamav/assets/cronjobs
