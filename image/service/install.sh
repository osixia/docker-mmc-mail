#!/bin/bash -e
# this script is run during the image build

groupadd -g 5000 vmail && useradd -g vmail -u 5000 vmail -d /var/mail

# backup default config files
cp /etc/postfix/main.cf /etc/postfix/main.cf.bak
cp /etc/postfix/master.cf /etc/postfix/master.cf.bak

# opendkim
cp /osixia/opendkim/config/opendkim.conf /etc/opendkim.conf
echo "SOCKET=\"inet:12301@localhost\"" >> /etc/default/opendkim
mkdir -p /etc/opendkim/keys

# spamassassin
sed -i "s/ENABLED=0/ENABLED=1/g" /etc/default/spamassassin
sed -i "s/CRON=0/CRON=1/g" /etc/default/spamassassin

cp /osixia/spamassassin/cronjobs /etc/cron.d/spamassassin

# dovecot sieve
mkdir /var/mail/sieve/
cp /osixia/dovecot/sieve/default.sieve /var/mail/sieve/default.sieve
chown -R vmail:vmail /var/mail/sieve
sievec /var/mail/sieve/default.sieve

# clamav
mkdir /var/spool/postfix/clamav
chown clamav /var/spool/postfix/clamav

sed -i "s|Foreground false|Foreground true|g" /etc/clamav/clamd.conf
cp /osixia/clamav/config/clamav-milter.conf /etc/clamav/clamav-milter.conf

freshclam
cp /osixia/clamav/cronjobs /etc/cron.d/clamav
