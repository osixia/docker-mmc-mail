#!/bin/sh

# -e Exit immediately if a command exits with a non-zero status
set -e

LDAP_HOST=${LDAP_HOST}
LDAP_BASE_DN=${LDAP_BASE_DN}

# dovecot is not already configured
if [ ! -e /etc/postfix/docker_bootstrapped ]; then

  sudo chmod g+s /usr/sbin/postdrop /usr/sbin/postqueue

  cp /usr/share/doc/mmc/contrib/mail/postfix/with-virtual-domains/* /etc/postfix/

  for i in `ls /etc/postfix/ldap-*.cf`;
  do 
    sed -i "s/server_host = 127.0.0.1/server_host = $LDAP_HOST/" $i;
    sed -i "s/server_port = 389/server_port = $LDAP_PORT/" $i;
    sed -i "s/dc=mandriva,dc=com/$LDAP_BASE_DN/" $i;
  done

  sed -i '/myorigin =/d' /etc/postfix/main.cf

  echo "# Dovecot LDA " >> /etc/postfix/main.cf
  echo "virtual_transport = dovecot" >> /etc/postfix/main.cf
  echo "dovecot_destination_recipient_limit = 1" >> /etc/postfix/main.cf

  cat /etc/postfix/config/sasl.cf >> /etc/postfix/main.cf
  cat /etc/postfix/config/spam.cf >> /etc/postfix/main.cf

  echo "# Dovecot LDA" >> /etc/postfix/master.cf
  echo "dovecot    unix  -       n       n       -       -       pipe " >> /etc/postfix/master.cf
  echo "    flags=DRhu user=vmail:mail argv=/usr/lib/dovecot/deliver -d \$recipient" >> /etc/postfix/master.cf

  echo "# SASL" >> /etc/postfix/master.cf
  echo "smtps     inet  n       -       -       -       -       smtpd " >> /etc/postfix/master.cf
  echo "  -o smtpd_tls_wrappermode=yes " >> /etc/postfix/master.cf
  echo "  -o smtpd_sasl_auth_enable=yes" >> /etc/postfix/master.cf

  touch /etc/postfix/docker_bootstrapped
else
  status "found already-configured dovecot"
fi

# exec /usr/sbin/dovecot -F



