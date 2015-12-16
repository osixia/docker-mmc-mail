#!/bin/bash -e

FIRST_START_DONE="/etc/docker-dovecot-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

	# ldap
	sed -i --follow-symlinks "s|{{ MMC_MAIL_LDAP_URL }}|${MMC_MAIL_LDAP_URL}|g" /etc/dovecot/dovecot-ldap.conf.ext
	sed -i --follow-symlinks "s|{{ MMC_MAIL_LDAP_BASE_DN }}|${MMC_MAIL_LDAP_BASE_DN}|g" /etc/dovecot/dovecot-ldap.conf.ext

	# ldap bind dn
	if [ -n "${MMC_MAIL_LDAP_BIND_DN}" ]; then
	  echo "dn = $MMC_MAIL_LDAP_BIND_DN" >> /etc/dovecot/dovecot-ldap.conf.ext

		# 	ldap bind password
	  if [ -n "${MMC_MAIL_LDAP_BIND_PW}" ]; then
	    echo "dnpass = $MMC_MAIL_LDAP_BIND_PW" >> /etc/dovecot/dovecot-ldap.conf.ext
	  fi
	fi

	# ldap tls config
	if [ "${MMC_MAIL_LDAP_CLIENT_TLS,,}" == "true" ]; then

		echo "tls = yes" >> /etc/dovecot/dovecot-ldap.conf.ext
		echo "tls_require_cert = $MMC_MAIL_LDAP_CLIENT_TLS_REQCERT" >> /etc/dovecot/dovecot-ldap.conf.ext
		echo "tls_ca_cert_file = /container/service/dovecot/assets/ldap-client/certs/$MMC_MAIL_LDAP_CLIENT_TLS_CA_CRT_FILENAME" >> /etc/dovecot/dovecot-ldap.conf.ext
		echo "tls_cert_file = /container/service/dovecot/assets/ldap-client/certs/$MMC_MAIL_LDAP_CLIENT_TLS_CRT_FILENAME" >> /etc/dovecot/dovecot-ldap.conf.ext
		echo "tls_key_file = /container/service/dovecot/assets/ldap-client/certs/$MMC_MAIL_LDAP_CLIENT_TLS_KEY_FILENAME" >> /etc/dovecot/dovecot-ldap.conf.ext
	fi

	# ssl
	sed -i --follow-symlinks "s|{{ MMC_MAIL_SSL_CRT_FILENAME }}|${MMC_MAIL_SSL_CRT_FILENAME}|g" /etc/dovecot/conf.d/10-ssl.conf
  sed -i --follow-symlinks "s|{{ MMC_MAIL_SSL_KEY_FILENAME }}|${MMC_MAIL_SSL_KEY_FILENAME}|g" /etc/dovecot/conf.d/10-ssl.conf
	sed -i --follow-symlinks "s|{{ MMC_MAIL_SSL_CA_CRT_FILENAME }}|${MMC_MAIL_SSL_CA_CRT_FILENAME}|g" /etc/dovecot/conf.d/10-ssl.conf

	if [ "${MMC_MAIL_REPLICATION,,}" == "true" ]; then
			/container/service/dovecot/assets/config/enable-config replication
	fi

	[ -f /etc/dovecot/dovecot-ldap-userdb.conf.ext ] && rm -f /etc/dovecot/dovecot-ldap-userdb.conf.ext
	cp /etc/dovecot/dovecot-ldap.conf.ext /etc/dovecot/dovecot-ldap-userdb.conf.ext

  touch $FIRST_START_DONE
fi

exit 0
