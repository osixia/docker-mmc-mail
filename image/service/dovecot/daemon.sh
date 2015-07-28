#!/bin/bash -e
if [ -e "/var/run/dovecot/master.pid" ] && rm -f /var/run/dovecot/master.pid
exec /usr/sbin/dovecot -F
