#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

ln -sf ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/config-available/replication/config/90-replication.conf /etc/dovecot/conf.d/90-replication.conf

FIRST_START_DONE="${CONTAINER_STATE_DIR}/docker-dovecot-replication-first-start-done"
# container first start
if [ ! -e "$FIRST_START_DONE" ]; then
  sed -i "s|mail_plugins = \$mail_plugins|mail_plugins = \$mail_plugins notify replication|g" ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/conf.d/10-mail.conf

  sed -i "s|{{ MMC_MAIL_REPLICATION_PASSWORD }}|${MMC_MAIL_REPLICATION_PASSWORD}|g" ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/config-available/replication/config/90-replication.conf
  sed -i "s|{{ MMC_MAIL_REPLICATION_HOST }}|${MMC_MAIL_REPLICATION_HOST}|g" ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/config-available/replication/config/90-replication.conf

  if [ "${MMC_MAIL_REPLICATION_SSL,,}" == "true" ]; then
    MMC_MAIL_REPLICATION_SSL_CRT_PATH="${CONTAINER_SERVICE_DIR}/postfix/assets/certs/${MMC_MAIL_REPLICATION_SSL_CRT_FILENAME}"
  	MMC_MAIL_REPLICATION_SSL_KEY_PATH="${CONTAINER_SERVICE_DIR}/postfix/assets/certs/${MMC_MAIL_REPLICATION_SSL_KEY_FILENAME}"
    MMC_MAIL_REPLICATION_SSL_CA_CRT_PATH="${CONTAINER_SERVICE_DIR}/postfix/assets/certs/${MMC_MAIL_REPLICATION_SSL_CA_CRT_FILENAME}"

    if [ -n "${MMC_MAIL_REPLICATION_LOCAL_NAME}" ]; then
      export ${MMC_MAIL_REPLICATION_SSL_HELPER_PREFIX}_CFSSL_HOSTNAME=${MMC_MAIL_REPLICATION_LOCAL_NAME}
      export ${MMC_MAIL_REPLICATION_SSL_HELPER_PREFIX}_JSONSSL_HOSTNAME=${MMC_MAIL_REPLICATION_LOCAL_NAME}
      echo "local_name ${MMC_MAIL_REPLICATION_LOCAL_NAME} {" >> ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/conf.d/10-ssl.conf
      echo "ssl_cert = <${MMC_MAIL_REPLICATION_SSL_CRT_PATH}" >> ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/conf.d/10-ssl.conf
      echo "ssl_key = <${MMC_MAIL_REPLICATION_SSL_KEY_PATH}" >> ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/conf.d/10-ssl.conf
      echo "}" >> ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/conf.d/10-ssl.conf
    fi

    echo "ssl_cert = <${MMC_MAIL_REPLICATION_SSL_CRT_PATH}" >> ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/conf.d/10-ssl.conf
    echo "ssl_key = <${MMC_MAIL_REPLICATION_SSL_KEY_PATH}" >> ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/conf.d/10-ssl.conf

    # generate a certificate and key if files don't exists
    # https://github.com/osixia/docker-light-baseimage/blob/stable/image/service-available/:json-tools/assets/tool/ssl-helper
    ssl-helper ${MMC_MAIL_REPLICATION_SSL_HELPER_PREFIX} "${MMC_MAIL_REPLICATION_SSL_CRT_PATH}" "${MMC_MAIL_REPLICATION_SSL_KEY_PATH}" "${MMC_MAIL_REPLICATION_SSL_CA_CRT_PATH}"

    echo "ssl_client_ca_file = ${MMC_MAIL_REPLICATION_SSL_CA_CRT_PATH}" >> ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/conf.d/10-ssl.conf

    sed -i "s|#ssl|ssl|g" ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/config-available/replication/config/90-replication.conf
    sed -i "s|tcp:|tcps:|g" ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/config-available/replication/config/90-replication.conf
  fi
fi

exit 0
