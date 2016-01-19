#!/bin/bash -e

FIRST_START_DONE="/etc/docker-ldap-client-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  if [ "${MMC_MAIL_LDAP_CLIENT_TLS,,}" == "true" ]; then

    # ldap ssl config
    # check certificat and key or create it
    /sbin/ssl-helper "${CONTAINER_SERVICE_DIR}/ldap-client/assets/certs/$MMC_MAIL_LDAP_CLIENT_TLS_CRT_FILENAME" "${CONTAINER_SERVICE_DIR}/ldap-client/assets/certs/$MMC_MAIL_LDAP_CLIENT_TLS_KEY_FILENAME" "${CONTAINER_SERVICE_DIR}/ldap-client/assets/certs/$MMC_MAIL_LDAP_CLIENT_TLS_CA_CRT_FILENAME"

    # ldap client config
    sed -i --follow-symlinks "s,TLS_CACERT.*,TLS_CACERT ${CONTAINER_SERVICE_DIR}/ldap-client/assets/certs/$MMC_MAIL_LDAP_CLIENT_TLS_CA_CRT_FILENAME,g" /etc/ldap/ldap.conf
    echo "TLS_REQCERT $MMC_MAIL_LDAP_CLIENT_TLS_REQCERT" >> /etc/ldap/ldap.conf

    [[ -f "$HOME/.ldaprc" ]] && rm -f $HOME/.ldaprc
    touch $HOME/.ldaprc

    echo "TLS_CERT ${CONTAINER_SERVICE_DIR}/ldap-client/assets/certs/$MMC_MAIL_LDAP_CLIENT_TLS_CRT_FILENAME" >> $HOME/.ldaprc
    echo "TLS_KEY ${CONTAINER_SERVICE_DIR}/ldap-client/assets/certs/$MMC_MAIL_LDAP_CLIENT_TLS_KEY_FILENAME" >> $HOME/.ldaprc

    LDAP_AUTH="$LDAP_AUTH -ZZ"

    mkdir -p ${CONTAINER_SERVICE_DIR}/dovecot/assets/ldap-client/certs
    mkdir -p ${CONTAINER_SERVICE_DIR}/postfix/assets/ldap-client/certs

    cp ${CONTAINER_SERVICE_DIR}/ldap-client/assets/certs/* ${CONTAINER_SERVICE_DIR}/dovecot/assets/ldap-client/certs
    cp ${CONTAINER_SERVICE_DIR}/ldap-client/assets/certs/* ${CONTAINER_SERVICE_DIR}/postfix/assets/ldap-client/certs

    chown -R dovecot:dovecot ${CONTAINER_SERVICE_DIR}/dovecot/assets/ldap-client/certs
    chown -R postfix:postfix ${CONTAINER_SERVICE_DIR}/postfix/assets/ldap-client/certs
  fi

  touch $FIRST_START_DONE
fi

exit 0
