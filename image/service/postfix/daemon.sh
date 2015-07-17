#!/bin/sh
 exec 1>&2

 daemon_directory=/usr/lib/postfix \
 command_directory=/usr/sbin \
 config_directory=/etc/postfix \
 queue_directory=/var/spool/postfix \
 mail_owner=postfix \
 setgid_group=postdrop \
   /etc/postfix/postfix-script check || exit 1

 exec /usr/lib/postfix/master
