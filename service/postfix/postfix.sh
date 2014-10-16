#!/bin/sh

# -e Exit immediately if a command exits with a non-zero status
set -e

LDAP_HOST=${LDAP_HOST}
LDAP_BASE_DN=${LDAP_BASE_DN}

# dovecot is not already configured
if [ ! -e /etc/postfix/docker_bootstrapped ]; then

  cp /usr/share/doc/mmc/contrib/mail/postfix/with-virtual-domains/ldap-* /etc/postfix/

  for i in `ls /etc/postfix/ldap-*.cf`;
  do 
    sed -i "s/server_host = 127.0.0.1/server_host = $LDAP_HOST/" $i;
    sed -i "s/server_port = 389/server_port = $LDAP_PORT/" $i;
    sed -i "s/dc=mandriva,dc=com/$LDAP_BASE_DN/" $i;
  done

  echo "virtual_transport = dovecot" >> /etc/postfix/main.cf
  echo "dovecot_destination_recipient_limit = 1" >> /etc/postfix/main.cf

  echo "# Dovecot LDA" >> /etc/postfix/master.cf
  echo "dovecot    unix  -       n       n       -       -       pipe " >> /etc/postfix/master.cf
  echo "    flags=DRhu user=vmail:mail argv=/usr/lib/dovecot/deliver -d \$recipient" >> /etc/postfix/master.cf

dovecot    unix  -       n       n       -       -       pipe 
    flags=DRhu user=vmail:mail argv=/usr/lib/dovecot/deliver -d $recipient

  # Set ldap host
  sed -i -e "s/127.0.0.1/$LDAP_HOST/g" /etc/dovecot/dovecot-ldap.conf.ext

  # Set ldap base dn
  sed -i -e "s/dc=example,dc=com/$LDAP_BASE_DN/g" /etc/dovecot/dovecot-ldap.conf.ext


  touch /etc/postfix/docker_bootstrapped
else
  status "found already-configured dovecot"
fi

exec /usr/sbin/dovecot -F


