#!/bin/bash -e

FIRST_START_DONE="/etc/docker-postfix-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # copy config
  cp /osixia/postfix/common/* /etc/postfix/
  cp /osixia/postfix/config/${POSTFIX_CONFIG}/* /etc/postfix/

  # set mailserver hostname
  sed -i "s/hostname.domain.tld/${SERVER_NAME}/g" /etc/postfix/main.cf


  # postfix ssl config
  

  
  # ldap config
  for i in `ls /etc/postfix/ldap-*.cf`;
  do 
    sed -i "s/127.0.0.1/$LDAP_URL/" $i;
    sed -i "s/dc=mandriva,dc=com/$LDAP_BASE_DN/" $i;*

    # create phpLDAPadmin vhost
    if [ "${LDAP_USE_TLS,,}" == "true" ]; then

      echo "start_tls = yes" >> $i;
      echo "tls_ca_cert_file = /etc/ssl/certs/docker_baseimage_gnutls_cacert.pem" >> $i;
      echo "tls_cert = /etc/ssl/smtp/$SMTP_SSL_CRT_FILENAME" >> $i;
      echo "tls_key = /etc/ssl/smtp/$SMTP_SSL_KEY_FILENAME" >> $i;
      echo "tls_require_cert = yes" >> $i;

    fi

  done

  touch $FIRST_START_DONE
fi

exit 0