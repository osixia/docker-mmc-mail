#!/bin/sh

# -e Exit immediately if a command exits with a non-zero status
set -e

$HOSTNAME=${HOSTNAME}
LDAP_HOST=${LDAP_HOST}
LDAP_BASE_DN=${LDAP_BASE_DN}
HOSTNAME=${HOSTNAME}
SMTP_SSL_CRT_FILENAME=${SMTP_SSL_CRT_FILENAME}
SMTP_SSL_KEY_FILENAME=${SMTP_SSL_KEY_FILENAME}

# dovecot is not already configured
if [ ! -e /etc/postfix/docker_bootstrapped ]; then

  # Generate ssl cert if needed
  mkdir -p /etc/ssl/smtp
  /sbin/create-ssl-cert $SMTP_HOSTNAME /etc/ssl/smtp/$SMTP_SSL_CRT_FILENAME /etc/ssl/smtp/$SMTP_SSL_KEY_FILENAME

  echo "$HOSTNAME" >> /etc/mailname

  sudo chmod g+s /usr/sbin/postdrop /usr/sbin/postqueue

  cp /usr/share/doc/mmc/contrib/mail/postfix/with-virtual-domains/* /etc/postfix/

  for i in `ls /etc/postfix/ldap-*.cf`;
  do 
    sed -i "s/server_host = 127.0.0.1/server_host = $LDAP_HOST/" $i;
    sed -i "s/server_port = 389/server_port = $LDAP_PORT/" $i;
    sed -i "s/dc=mandriva,dc=com/$LDAP_BASE_DN/" $i;
  done

  echo "# Dovecot LDA " >> /etc/postfix/main.cf
  echo "virtual_transport = dovecot" >> /etc/postfix/main.cf
  echo "dovecot_destination_recipient_limit = 1" >> /etc/postfix/main.cf

  cat /etc/postfix/config/sasl.cf >> /etc/postfix/main.cf
  cat /etc/postfix/config/spam.cf >> /etc/postfix/main.cf


  # SSL 
  echo "# TLS/SSL " >> /etc/postfix/main.cf
  echo "smtpd_tls_security_level = may" >> /etc/postfix/main.cf
  echo "smtpd_tls_loglevel = 1" >> /etc/postfix/main.cf
  echo "smtpd_tls_cert_file = /etc/ssl/smtp/$SMTP_SSL_CRT_FILENAME" >> /etc/postfix/main.cf
  echo "smtpd_tls_key_file = /etc/ssl/smtp/$SMTP_SSL_KEY_FILENAME" >> /etc/postfix/main.cf

  echo "# Dovecot LDA" >> /etc/postfix/master.cf
  echo "dovecot    unix  -       n       n       -       -       pipe " >> /etc/postfix/master.cf
  echo "    flags=DRhu user=vmail:mail argv=/usr/lib/dovecot/deliver -d \$recipient" >> /etc/postfix/master.cf

  echo "# SASL" >> /etc/postfix/master.cf
  echo "smtps     inet  n       -       -       -       -       smtpd " >> /etc/postfix/master.cf
  echo "  -o smtpd_tls_wrappermode=yes " >> /etc/postfix/master.cf
  echo "  -o smtpd_sasl_auth_enable=yes" >> /etc/postfix/master.cf

  #SSL
  echo "smtps     inet  n       -       -       -       -       smtpd " >> /etc/postfix/master.cf
  echo "  -o smtpd_tls_wrappermode=yes " >> /etc/postfix/master.cf
  echo "  -o smtpd_sasl_auth_enable=yes" >> /etc/postfix/master.cf

  postfix-add-filter amavis 10025

  touch /etc/postfix/sender_access_catchall
  echo "/^/ FILTER amavis:[127.0.0.1]:10024" >> /etc/postfix/sender_access_catchall


  touch /etc/postfix/docker_bootstrapped
else
  status "found already-configured dovecot"
fi

# exec /usr/sbin/dovecot -F



