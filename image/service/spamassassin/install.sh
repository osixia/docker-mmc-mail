#!/bin/bash -e
# this script is run during the image build

# spamassassin
sed -i --follow-symlinks "s/ENABLED=0/ENABLED=1/g" /etc/default/spamassassin
sed -i --follow-symlinks "s/CRON=0/CRON=1/g" /etc/default/spamassassin

ln -s -f /container/service/spamassassin/assets/config/* /etc/spamassassin/
ln -s /container/service/spamassassin/assets/cronjobs /etc/cron.d/spamassassin
chmod 600 /container/service/spamassassin/assets/cronjobs
