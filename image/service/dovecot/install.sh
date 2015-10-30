#!/bin/bash -e
# this script is run during the image build

# dovecot
ln -s -f /container/service/dovecot/assets/config/dovecot.conf /etc/dovecot/dovecot.conf
ln -s -f /container/service/dovecot/assets/config/dovecot-ldap.conf.ext /etc/dovecot/dovecot-ldap.conf.ext
ln -s -f /container/service/dovecot/assets/config/dovecot-ldap.conf.ext /etc/dovecot/dovecot-ldap-userdb.conf.ext
ln -s -f /container/service/dovecot/assets/config/conf.d/* /etc/dovecot/conf.d
