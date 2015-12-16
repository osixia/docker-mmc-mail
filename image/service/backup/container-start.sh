#!/bin/bash -e

FIRST_START_DONE="/etc/docker-backup-backup-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # adapt cronjobs file
  sed -i --follow-symlinks "s|{{ MMC_MAIL_BACKUP_CRON_EXP }}|${MMC_MAIL_BACKUP_CRON_EXP}|g" /container/service/backup/assets/cronjobs

  touch $FIRST_START_DONE
fi

exit 0
