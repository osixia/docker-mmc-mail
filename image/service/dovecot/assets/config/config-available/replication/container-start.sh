#!/bin/bash -e

ln -s /osixia/dovecot/config/config-available/replication/config/90-replication.conf /etc/dovecot/conf.d/90-replication.conf
sed -i "s|mail_plugins = \$mail_plugins|mail_plugins = \$mail_plugins notify replication|g" /etc/dovecot/conf.d/10-mail.conf

exit 0
