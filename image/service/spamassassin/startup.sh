#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

# add config
ln -sf ${CONTAINER_SERVICE_DIR}/spamassassin/assets/config/* /etc/spamassassin/

# add cron jobs
ln -sf ${CONTAINER_SERVICE_DIR}/spamassassin/assets/cronjobs /etc/cron.d/spamassassin
chmod 600 ${CONTAINER_SERVICE_DIR}/spamassassin/assets/cronjobs

FIRST_START_DONE="${CONTAINER_STATE_DIR}/docker-spamassassin-first-start-done"
# container first start
if [ ! -e "$FIRST_START_DONE" ]; then
    
    # adapt cronjobs file
    log-helper info "Configure cronjobs"
    sed -i "s|{{ MMC_MAIL_SPAMASSASSIN_UPDATE_CRON_EXP }}|${MMC_MAIL_SPAMASSASSIN_UPDATE_CRON_EXP}|g" ${CONTAINER_SERVICE_DIR}/spamassassin/assets/cronjobs
    sed -i "s|{{ MMC_MAIL_SPAMASSASSIN_HAM_CRON_EXP }}|${MMC_MAIL_SPAMASSASSIN_HAM_CRON_EXP}|g" ${CONTAINER_SERVICE_DIR}/spamassassin/assets/cronjobs
    sed -i "s|{{ MMC_MAIL_SPAMASSASSIN_SPAM_CRON_EXP }}|${MMC_MAIL_SPAMASSASSIN_SPAM_CRON_EXP}|g" ${CONTAINER_SERVICE_DIR}/spamassassin/assets/cronjobs
    
    log-helper info "Learn ham"
    sa-learn --ham /var/mail/vhosts/*/*/cur/*

    log-helper info "Learn spam"
    sa-learn --spam /var/mail/vhosts/*/*/.Spam/cur/*

    touch $FIRST_START_DONE
fi

exit 0
