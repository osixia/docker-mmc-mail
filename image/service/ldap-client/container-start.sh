#!/bin/bash -e

FIRST_START_DONE="/etc/docker-ldap-client-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  if [ "${MMC_MAIL_LDAP_CLIENT_TLS,,}" == "true" ]; then

    # ldap ssl config
    # check certificat and key or create it
    /sbin/ssl-helper "/container/service/ldap-client/assets/certs/$MMC_MAIL_LDAP_CLIENT_TLS_CRT_FILENAME" "/container/service/ldap-client/assets/certs/$MMC_MAIL_LDAP_CLIENT_TLS_KEY_FILENAME" --ca-crt=/container/service/ldap-client/assets/certs/$MMC_MAIL_LDAP_CLIENT_TLS_CA_CRT_FILENAME  --gnutls

    # ldap client config
    sed -i "s,TLS_CACERT.*,TLS_CACERT /container/service/ldap-client/assets/certs/$MMC_MAIL_LDAP_CLIENT_TLS_CA_CRT_FILENAME,g" /etc/ldap/ldap.conf
    echo "TLS_REQCERT $MMC_MAIL_LDAP_CLIENT_TLS_REQCERT" >> /etc/ldap/ldap.conf

    [[ -f "~/.ldaprc" ]] && rm -f ~/.ldaprc
    touch ~/.ldaprc

    echo "TLS_CERT /container/service/ldap-client/assets/certs/$MMC_MAIL_LDAP_CLIENT_TLS_CRT_FILENAME" >> ~/.ldaprc
    echo "TLS_KEY /container/service/ldap-client/assets/certs/$MMC_MAIL_LDAP_CLIENT_TLS_KEY_FILENAME" >> ~/.ldaprc

    LDAP_AUTH="$LDAP_AUTH -ZZ"

    mkdir -p /container/service/dovecot/assets/ldap-client/certs
    mkdir -p /container/service/postfix/assets/ldap-client/certs

    cp /container/service/ldap-client/assets/certs/* /container/service/dovecot/assets/ldap-client/certs
    cp /container/service/ldap-client/assets/certs/* /container/service/postfix/assets/ldap-client/certs

    chown -R dovecot:dovecot /container/service/dovecot/assets/ldap-client/certs
    chown -R postfix:postfix /container/service/postfix/assets/ldap-client/certs
  fi

  touch $FIRST_START_DONE
fi

exit 0
