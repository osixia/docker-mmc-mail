#!/bin/bash -e

FIRST_START_DONE="/etc/docker-dovecot-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

	cp -R /osixia/dovecot/config/* /etc/dovecot

	sed -i "s,ldap://ldap.example.org:389,$LDAP_URL," /etc/dovecot/dovecot-ldap.conf.ext
	sed -i "s/dc=mandriva,dc=com/$LDAP_BASE_DN/" /etc/dovecot/dovecot-ldap.conf.ext

	# ssl
	sed -i "s,/osixia/postfix/ssl/mailserver.crt,/osixia/postfix/ssl/${SSL_CRT_FILENAME},g" /etc/dovecot/conf.d/10-ssl.conf
    sed -i "s,/osixia/postfix/ssl/mailserver.key,/osixia/postfix/ssl/${SSL_KEY_FILENAME},g" /etc/dovecot/conf.d/10-ssl.conf

  touch $FIRST_START_DONE
fi

exit 0