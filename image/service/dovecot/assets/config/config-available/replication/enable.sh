#!/bin/bash -e

ln -s /osixia/dovecot/config/config-available/replication/config/90-replication.conf /etc/dovecot/conf.d/90-replication.conf
sed -i "s|mail_plugins = \$mail_plugins|mail_plugins = \$mail_plugins notify replication|g" /etc/dovecot/conf.d/10-mail.conf

sed -i "s|anotherhost.example.com|${REPLICATION_HOST}|g" /osixia/dovecot/config/config-available/replication/config/90-replication.conf

if [ "${REPLICATION_USE_SSL,,}" == "true" ]; then
  sed -i "s|#ssl =|ssl =|g" /osixia/dovecot/config/config-available/replication/config/90-replication.conf
  sed -i "s|tcp:|tcps:|g" /osixia/dovecot/config/config-available/replication/config/90-replication.conf
fi

exit 0
