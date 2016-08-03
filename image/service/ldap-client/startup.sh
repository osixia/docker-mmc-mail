#!/bin/bash -e

FIRST_START_DONE="${CONTAINER_STATE_DIR}/docker-ldap-client-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  if [ "${MMC_MAIL_LDAP_CLIENT_TLS,,}" == "true" ]; then

    # generate a certificate and key if files don't exists
    # https://github.com/osixia/docker-light-baseimage/blob/stable/image/service-available/:ssl-tools/assets/tool/ssl-helper
    ssl-helper ${LDAP_CLIENT_SSL_HELPER_PREFIX} "${CONTAINER_SERVICE_DIR}/ldap-client/assets/certs/$MMC_MAIL_LDAP_CLIENT_TLS_CRT_FILENAME" "${CONTAINER_SERVICE_DIR}/ldap-client/assets/certs/$MMC_MAIL_LDAP_CLIENT_TLS_KEY_FILENAME" "${CONTAINER_SERVICE_DIR}/ldap-client/assets/certs/$MMC_MAIL_LDAP_CLIENT_TLS_CA_CRT_FILENAME"

    # ldap client config
    sed -i --follow-symlinks "s,TLS_CACERT.*,TLS_CACERT ${CONTAINER_SERVICE_DIR}/ldap-client/assets/certs/$MMC_MAIL_LDAP_CLIENT_TLS_CA_CRT_FILENAME,g" /etc/ldap/ldap.conf
    echo "TLS_REQCERT $MMC_MAIL_LDAP_CLIENT_TLS_REQCERT" >> /etc/ldap/ldap.conf
    cp -f /etc/ldap/ldap.conf ${CONTAINER_SERVICE_DIR}/ldap-client/assets/ldap.conf

    [[ -f "$HOME/.ldaprc" ]] && rm -f $HOME/.ldaprc
    echo "TLS_CERT ${CONTAINER_SERVICE_DIR}/ldap-client/assets/certs/$MMC_MAIL_LDAP_CLIENT_TLS_CRT_FILENAME" > $HOME/.ldaprc
    echo "TLS_KEY ${CONTAINER_SERVICE_DIR}/ldap-client/assets/certs/$MMC_MAIL_LDAP_CLIENT_TLS_KEY_FILENAME" >> $HOME/.ldaprc
    cp -f $HOME/.ldaprc ${CONTAINER_SERVICE_DIR}/ldap-client/assets/.ldaprc

    mkdir -p ${CONTAINER_SERVICE_DIR}/dovecot/assets/ldap-client/certs
    mkdir -p ${CONTAINER_SERVICE_DIR}/postfix/assets/ldap-client/certs

    cp -f ${CONTAINER_SERVICE_DIR}/ldap-client/assets/certs/* ${CONTAINER_SERVICE_DIR}/dovecot/assets/ldap-client/certs
    cp -f ${CONTAINER_SERVICE_DIR}/ldap-client/assets/certs/* ${CONTAINER_SERVICE_DIR}/postfix/assets/ldap-client/certs

    chown -R dovecot:dovecot ${CONTAINER_SERVICE_DIR}/dovecot/assets/ldap-client/certs
    chown -R postfix:postfix ${CONTAINER_SERVICE_DIR}/postfix/assets/ldap-client/certs
  fi

  touch $FIRST_START_DONE
fi

ln -sf ${CONTAINER_SERVICE_DIR}/ldap-client/assets/.ldaprc $HOME/.ldaprc
ln -sf ${CONTAINER_SERVICE_DIR}/ldap-client/assets/ldap.conf /etc/ldap/ldap.conf

exit 0
