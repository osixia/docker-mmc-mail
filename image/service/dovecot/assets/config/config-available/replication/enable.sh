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
    sed -i "s|#ssl =|ssl =|g" ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/config-available/replication/config/90-replication.conf
    sed -i "s|tcp:|tcps:|g" ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/config-available/replication/config/90-replication.conf
  fi
fi

exit 0
