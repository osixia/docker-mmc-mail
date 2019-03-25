#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

# add cron jobs
ln -sf ${CONTAINER_SERVICE_DIR}/clamav/assets/cronjobs /etc/cron.d/clamav
chmod 600 ${CONTAINER_SERVICE_DIR}/clamav/assets/cronjobs

FIRST_START_DONE="${CONTAINER_STATE_DIR}/docker-clamav-first-start-done"
# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # adapt cronjobs file
  sed -i "s|{{ MMC_MAIL_FRESHCLAM_CRON_EXP }}|${MMC_MAIL_FRESHCLAM_CRON_EXP}|g" ${CONTAINER_SERVICE_DIR}/clamav/assets/cronjobs

  touch $FIRST_START_DONE
fi

exit 0
