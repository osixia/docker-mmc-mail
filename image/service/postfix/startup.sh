#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

# postfix
ln -sf ${CONTAINER_SERVICE_DIR}/postfix/assets/config/* /etc/postfix/

FIRST_START_DONE="${CONTAINER_STATE_DIR}/docker-postfix-first-start-done"
# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # set mailserver hostname
  sed -i "s|{{ HOSTNAME }}|${HOSTNAME}|g" ${CONTAINER_SERVICE_DIR}/postfix/assets/config/main.cf

  # Mailserver ssl config
  # check certificat and key or create it
  /sbin/ssl-helper "${CONTAINER_SERVICE_DIR}/postfix/assets/certs/$MMC_MAIL_SSL_CRT_FILENAME" "${CONTAINER_SERVICE_DIR}/postfix/assets/certs/$MMC_MAIL_SSL_KEY_FILENAME" "${CONTAINER_SERVICE_DIR}/postfix/assets/certs/$MMC_MAIL_SSL_CA_CRT_FILENAME"

  MMC_MAIL_SSL_CA_CRT_PATH="${CONTAINER_SERVICE_DIR}/postfix/assets/certs/${MMC_MAIL_SSL_CA_CRT_FILENAME}"
  MMC_MAIL_SSL_CRT_PATH="${CONTAINER_SERVICE_DIR}/postfix/assets/certs/${MMC_MAIL_SSL_CRT_FILENAME}"
  MMC_MAIL_SSL_KEY_PATH="${CONTAINER_SERVICE_DIR}/postfix/assets/certs/${MMC_MAIL_SSL_KEY_FILENAME}"

  # adapt tls config
  sed -i "s|{{ MMC_MAIL_SSL_CA_CRT_PATH }}|${MMC_MAIL_SSL_CA_CRT_PATH}|g" ${CONTAINER_SERVICE_DIR}/postfix/assets/config/main.cf
  sed -i "s|{{ MMC_MAIL_SSL_CRT_PATH }}|${MMC_MAIL_SSL_CRT_PATH}|g" ${CONTAINER_SERVICE_DIR}/postfix/assets/config/main.cf
  sed -i "s|{{ MMC_MAIL_SSL_KEY_PATH }}|${MMC_MAIL_SSL_KEY_PATH}|g" ${CONTAINER_SERVICE_DIR}/postfix/assets/config/main.cf

  MMC_MAIL_SSL_DHPARAM_512_PATH="${CONTAINER_SERVICE_DIR}/postfix/assets/certs/${MMC_MAIL_SSL_DHPARAM_512}"
  MMC_MAIL_SSL_DHPARAM_1024_PATH="${CONTAINER_SERVICE_DIR}/postfix/assets/certs/${MMC_MAIL_SSL_DHPARAM_1024}"

  sed -i "s|{{ MMC_MAIL_SSL_DHPARAM_512_PATH }}|${MMC_MAIL_SSL_DHPARAM_512_PATH}|g" ${CONTAINER_SERVICE_DIR}/postfix/assets/config/main.cf
  sed -i "s|{{ MMC_MAIL_SSL_DHPARAM_1024_PATH }}|${MMC_MAIL_SSL_DHPARAM_1024_PATH}|g" ${CONTAINER_SERVICE_DIR}/postfix/assets/config/main.cf

  # ldap config
  for i in `ls ${CONTAINER_SERVICE_DIR}/postfix/assets/config/ldap-*.cf`;
  do
    sed -i "s|{{ MMC_MAIL_LDAP_URL }}|${MMC_MAIL_LDAP_URL}|g" $i;
    sed -i "s|{{ MMC_MAIL_LDAP_BASE_DN }}|${MMC_MAIL_LDAP_BASE_DN}|g" $i;

    # ldap bind dn
    if [ -n "${MMC_MAIL_LDAP_BIND_DN}" ]; then
      echo "bind = yes" >> $i;
      echo "bind_dn = $MMC_MAIL_LDAP_BIND_DN" >> $i;

      # ldap bind password
      if [ -n "${MMC_MAIL_LDAP_BIND_PW}" ]; then
        echo "bind_pw = $MMC_MAIL_LDAP_BIND_PW" >> $i;
      fi
    fi

    # ldap tls config
    if [ "${MMC_MAIL_LDAP_CLIENT_TLS,,}" == "true" ]; then

      REQCERT="no"

      if [ "${MMC_MAIL_LDAP_CLIENT_TLS_REQCERT,,}" == "demand" ]; then
        REQCERT="yes"
      fi

      echo "start_tls = yes" >> $i;
      echo "tls_require_cert = $REQCERT" >> $i;
      echo "tls_ca_cert_file = ${CONTAINER_SERVICE_DIR}/postfix/assets/ldap-client/certs/$MMC_MAIL_LDAP_CLIENT_TLS_CA_CRT_FILENAME" >> $i;
      echo "tls_cert = ${CONTAINER_SERVICE_DIR}/postfix/assets/ldap-client/certs/$MMC_MAIL_LDAP_CLIENT_TLS_CRT_FILENAME" >> $i;
      echo "tls_key = ${CONTAINER_SERVICE_DIR}/postfix/assets/ldap-client/certs/$MMC_MAIL_LDAP_CLIENT_TLS_KEY_FILENAME" >> $i;
    fi
  done

  touch $FIRST_START_DONE
fi

# prevent fatal: unknown service: smtp/tcp
# http://serverfault.com/questions/655116/postfix-fails-to-send-mail-with-fatal-unknown-service-smtp-tcp
cp -f /etc/services /var/spool/postfix/etc/services

# copy dns settings to chroot jail
cp -f /etc/resolv.conf /var/spool/postfix/etc/resolv.conf


# set hosts
echo "127.0.0.1 localhost.localdomain" >> /etc/hosts

# fix files permissions
chown -R vmail:vmail /var/mail
chmod 644 /etc/postfix/*.cf
chmod 644 ${CONTAINER_SERVICE_DIR}/postfix/config/${CONTAINER_SERVICE_DIR}

exit 0
