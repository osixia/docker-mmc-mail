#!/bin/bash -e
# this script is run during the image build

# clamav
mkdir -p /var/run/clamav/
chown clamav /var/run/clamav/

#sed -i "s|db.local.clamav.net|db.fr.clamav.net|g" /etc/clamav/freshclam.conf

mkdir /var/spool/postfix/clamav
chown clamav /var/spool/postfix/clamav

sed -i "s|Foreground false|Foreground true|g" /etc/clamav/clamd.conf
