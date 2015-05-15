#!/bin/bash -e
# this script is run during the image build

groupadd -g 5000 vmail && useradd -g vmail -u 5000 vmail -d /var/mail

# backup default config files
cp /etc/postfix/main.cf /etc/postfix/main.cf.bak
cp /etc/postfix/master.cf /etc/postfix/master.cf.bak
cp /osixia/postfix/config/common/* /etc/postfix/

# opendkim
mkdir -p /etc/opendkim/keys
cp /osixia/opendkim/config/opendkim.conf /etc/opendkim.conf
ln -s /osixia/opendkim/config/TrustedHosts /etc/opendkim/TrustedHosts

ln -s /osixia/opendkim/keys/* /etc/opendkim/keys

echo "SOCKET=\"inet:12301@localhost\"" >> /etc/default/opendkim

# spamassassin
sed -i "s/ENABLED=0/ENABLED=1/g" /etc/default/spamassassin
sed -i "s/CRON=0/CRON=1/g" /etc/default/spamassassin

ln -s /osixia/spamassassin/cronjobs /etc/cron.d/spamassassin

# dovecot / dovecot sieve
cp -R /osixia/dovecot/config/* /etc/dovecot

mkdir /var/mail/sieve/
ln -s /osixia/dovecot/sieve/default.sieve /var/mail/sieve/default.sieve
chown -R vmail:vmail /var/mail/sieve
sievec /var/mail/sieve/default.sieve

# clamav
mkdir -p /var/run/clamav/
chown clamav /var/run/clamav/

sed -i "s|db.local.clamav.net|db.fr.clamav.net|g" /etc/clamav/freshclam.conf

mkdir /var/spool/postfix/clamav
chown clamav /var/spool/postfix/clamav

sed -i "s|Foreground false|Foreground true|g" /etc/clamav/clamd.conf
cp /osixia/clamav/config/clamav-milter.conf /etc/clamav/clamav-milter.conf

freshclam  -v
ln -s /osixia/clamav/cronjobs /etc/cron.d/clamav
