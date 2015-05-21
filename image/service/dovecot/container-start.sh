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

	# ldap tls config
	if [ "${LDAP_USE_TLS,,}" == "true" ]; then
		echo "tls = no" >> /etc/dovecot/dovecot-ldap.conf.ext
		echo "tls_ca_cert_file = /osixia/postfix/ssl/$LDAP_SSL_CA_CRT_FILENAME" >> /etc/dovecot/dovecot-ldap.conf.ext
		echo "tls_cert_file = /osixia/postfix/ssl/$LDAP_SSL_CRT_FILENAME" >> /etc/dovecot/dovecot-ldap.conf.ext
		echo "tls_key_file = /osixia/postfix/ssl/$LDAP_SSL_KEY_FILENAME" >> /etc/dovecot/dovecot-ldap.conf.ext
	fi


	# ssl
	sed -i "s,/osixia/postfix/ssl/mailserver.crt,/osixia/postfix/ssl/${SSL_CRT_FILENAME},g" /etc/dovecot/conf.d/10-ssl.conf
  sed -i "s,/osixia/postfix/ssl/mailserver.key,/osixia/postfix/ssl/${SSL_KEY_FILENAME},g" /etc/dovecot/conf.d/10-ssl.conf
	sed -i "s,/osixia/postfix/ssl/ca.crt,/osixia/postfix/ssl/${SSL_CA_CRT_FILENAME},g" /etc/dovecot/conf.d/10-ssl.conf

	if [ "${ENABLE_REPLICATION,,}" == "true" ]; then
			/osixia/dovecot/config/enable-config replication
	fi

  touch $FIRST_START_DONE
fi

sievec /var/mail/sieve/default.sieve

exec /usr/sbin/dovecot

exit 0
