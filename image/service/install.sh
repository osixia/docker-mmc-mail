#!/bin/bash -e
# this script is run during the image build

groupadd -g 5000 vmail && useradd -g vmail -u 5000 vmail -d /var/mail

# backup default config files
mv /etc/postfix/main.cf /etc/postfix/main.cf.bak
mv /etc/postfix/master.cf /etc/postfix/master.cf.bak
ln -s -f /osixia/postfix/config/* /etc/postfix/

# opendkim
mkdir -p /etc/opendkim/keys
ln -s -f /osixia/opendkim/config/opendkim.conf /etc/opendkim.conf
ln -s /osixia/opendkim/config/TrustedHosts /etc/opendkim/TrustedHosts

ln -s /osixia/opendkim/keys/* /etc/opendkim/keys

echo "SOCKET=\"inet:12301@localhost\"" >> /etc/default/opendkim

# spamassassin
sed -i "s/ENABLED=0/ENABLED=1/g" /etc/default/spamassassin
sed -i "s/CRON=0/CRON=1/g" /etc/default/spamassassin

ln -s -f /osixia/spamassassin/config/* /etc/spamassassin/
ln -s /osixia/spamassassin/cronjobs /etc/cron.d/spamassassin
chmod 600 /osixia/spamassassin/cronjobs

# dovecot / dovecot sieve
ln -s -f /osixia/dovecot/config/dovecot.conf /etc/dovecot/dovecot.conf
ln -s -f /osixia/dovecot/config/dovecot-ldap.conf.ext /etc/dovecot/dovecot-ldap.conf.ext
ln -s -f /osixia/dovecot/config/conf.d/* /etc/dovecot/conf.d

mkdir /var/mail/sieve/
ln -s /osixia/dovecot/sieve/default.sieve /var/mail/sieve/default.sieve
chown -R vmail:vmail /var/mail/sieve

# clamav
mkdir -p /var/run/clamav/
chown clamav /var/run/clamav/

#sed -i "s|db.local.clamav.net|db.fr.clamav.net|g" /etc/clamav/freshclam.conf

mkdir /var/spool/postfix/clamav
chown clamav /var/spool/postfix/clamav

sed -i "s|Foreground false|Foreground true|g" /etc/clamav/clamd.conf
ln -s -f /osixia/clamav/config/clamav-milter.conf /etc/clamav/clamav-milter.conf

freshclam  -v
ln -s /osixia/clamav/cronjobs /etc/cron.d/clamav
chmod 600 /osixia/clamav/cronjobs
