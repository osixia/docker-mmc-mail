#!/bin/bash -e

FIRST_START_DONE="/etc/docker-postfix-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # set mailserver hostname
  sed -i "s/hostname.domain.tld/${HOSTNAME}/g" /etc/postfix/main.cf

  # postfix ssl config
  # check certificat and key or create it
  /sbin/ssl-helper "/container/service/postfix/assets/ssl/$SSL_CRT_FILENAME" "/container/service/postfix/assets/ssl/$SSL_KEY_FILENAME" --ca-crt=/container/service/postfix/assets/ssl/$SSL_CA_CRT_FILENAME

  # adapt tls ldif
  sed -i "s,/container/service/postfix/assets/ssl/ca.crt,/container/service/postfix/assets/ssl/${SSL_CA_CRT_FILENAME},g" /etc/postfix/main.cf
  sed -i "s,/container/service/postfix/assets/ssl/mailserver.crt,/container/service/postfix/assets/ssl/${SSL_CRT_FILENAME},g" /etc/postfix/main.cf
  sed -i "s,/container/service/postfix/assets/ssl/mailserver.key,/container/service/postfix/assets/ssl/${SSL_KEY_FILENAME},g" /etc/postfix/main.cf

  # ldap config
  for i in `ls /etc/postfix/ldap-*.cf`;
  do
    sed -i "s,127.0.0.1,$LDAP_URL," $i;
    sed -i "s/dc=mandriva,dc=com/$LDAP_BASE_DN/" $i;

    # ldap bind dn
    if [ -n "${LDAP_BIND_DN}" ]; then
      echo "bind = yes" >> $i;
      echo "bind_dn = $LDAP_BIND_DN" >> $i;

      # ldap bind password
      if [ -n "${LDAP_BIND_PW}" ]; then
        echo "bind_pw = $LDAP_BIND_PW" >> $i;
      fi
    fi

    # ldap tls config
    if [ "${LDAP_CLIENT_USE_TLS,,}" == "true" ]; then

      # ldap ssl config
      # check certificat and key or create it
      /sbin/ssl-helper "/container/service/postfix/assets/ssl/$LDAP_CLIENT_TLS_CRT_FILENAME" "/container/service/postfix/assets/ssl/$LDAP_CLIENT_TLS_KEY_FILENAME" --ca-crt=/container/service/postfix/assets/ssl/$LDAP_CLIENT_TLS_CA_CRT_FILENAME

      echo "start_tls = no" >> $i;
      echo "tls_ca_cert_file = /container/service/postfix/assets/ssl/$LDAP_CLIENT_TLS_CA_CRT_FILENAME" >> $i;
      echo "tls_cert = /container/service/postfix/assets/ssl/$LDAP_CLIENT_TLS_CRT_FILENAME" >> $i;
      echo "tls_key = /container/service/postfix/assets/ssl/$LDAP_CLIENT_TLS_KEY_FILENAME" >> $i;
      echo "tls_require_cert = no" >> $i;
    fi
  done

  touch $FIRST_START_DONE
fi

# set hosts
echo "127.0.0.1 localhost.localdomain" >> /etc/hosts

# fix files permissions
chown -R vmail:vmail /var/mail

exit 0
