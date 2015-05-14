#!/bin/bash -e

FIRST_START_DONE="/etc/docker-dovecot-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

	# ldap
	sed -i "s,ldap://ldap.example.org:389,$LDAP_URL," /etc/dovecot/dovecot-ldap.conf.ext
	sed -i "s/dc=mandriva,dc=com/$LDAP_BASE_DN/" /etc/dovecot/dovecot-ldap.conf.ext

	# ldap bind dn
	if [ -n "${LDAP_BIND_DN}" ]; then
	  echo "dn = $LDAP_BIND_DN" >> /etc/dovecot/dovecot-ldap.conf.ext

		# 	ldap bind password
	  if [ -n "${LDAP_BIND_PW}" ]; then
	    echo "dnpass = $LDAP_BIND_PW" >> /etc/dovecot/dovecot-ldap.conf.ext
	  fi
	fi


	# ssl
	sed -i "s,/osixia/postfix/ssl/mailserver.crt,/osixia/postfix/ssl/${SSL_CRT_FILENAME},g" /etc/dovecot/conf.d/10-ssl.conf
  sed -i "s,/osixia/postfix/ssl/mailserver.key,/osixia/postfix/ssl/${SSL_KEY_FILENAME},g" /etc/dovecot/conf.d/10-ssl.conf

  touch $FIRST_START_DONE
fi

exec /usr/sbin/dovecot

exit 0
