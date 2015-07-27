#!/bin/bash -e

ln -s /container/service/dovecot/assets/config/config-available/replication/config/90-replication.conf /etc/dovecot/conf.d/90-replication.conf
sed -i "s|mail_plugins = \$mail_plugins|mail_plugins = \$mail_plugins notify replication|g" /etc/dovecot/conf.d/10-mail.conf

sed -i "s|anotherhost.example.com|${MMC_MAIL_REPLICATION_HOST}|g" /container/service/dovecot/assets/config/config-available/replication/config/90-replication.conf

if [ "${MMC_MAIL_REPLICATION_SSL,,}" == "true" ]; then
  sed -i "s|#ssl =|ssl =|g" /container/service/dovecot/assets/config/config-available/replication/config/90-replication.conf
  sed -i "s|tcp:|tcps:|g" /container/service/dovecot/assets/config/config-available/replication/config/90-replication.conf
fi

exit 0
