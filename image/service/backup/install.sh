#!/bin/bash -e
# this script is run during the image build

# install image tools
ln -s /container/service/backup/assets/tool/* /sbin/

# add cron jobs
ln -s /container/service/backup/assets/cronjobs /etc/cron.d/backup
chmod 600 /container/service/backup/assets/cronjobs
