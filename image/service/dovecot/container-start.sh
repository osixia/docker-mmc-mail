#!/bin/bash -e

FIRST_START_DONE="/etc/docker-dovecot-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

	# ldap
	sed -i "s,ldap://ldap.example.org:389,$MMC_MAIL_LDAP_URL," /etc/dovecot/dovecot-ldap.conf.ext
	sed -i "s/dc=mandriva,dc=com/$MMC_MAIL_LDAP_BASE_DN/" /etc/dovecot/dovecot-ldap.conf.ext

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
		echo "tls = no" >> /etc/dovecot/dovecot-ldap.conf.ext
		echo "tls_ca_cert_file = /container/service/postfix/assets/ldap-client/certs/$MMC_MAIL_LDAP_CLIENT_TLS_CA_CRT_FILENAME" >> /etc/dovecot/dovecot-ldap.conf.ext
		echo "tls_cert_file = /container/service/postfix/assets/ldap-client/certs/$MMC_MAIL_LDAP_CLIENT_TLS_CRT_FILENAME" >> /etc/dovecot/dovecot-ldap.conf.ext
		echo "tls_key_file = /container/service/postfix/assets/ldap-client/certs/$MMC_MAIL_LDAP_CLIENT_TLS_KEY_FILENAME" >> /etc/dovecot/dovecot-ldap.conf.ext
	fi


	# ssl
	sed -i "s,/container/service/postfix/assets/certs/mailserver.crt,/container/service/postfix/assets/certs/${MMC_MAIL_SSL_CRT_FILENAME},g" /etc/dovecot/conf.d/10-ssl.conf
  sed -i "s,/container/service/postfix/assets/certs/mailserver.key,/container/service/postfix/assets/certs/${MMC_MAIL_SSL_KEY_FILENAME},g" /etc/dovecot/conf.d/10-ssl.conf
	sed -i "s,/container/service/postfix/assets/certs/ca.crt,/container/service/postfix/assets/certs/${MMC_MAIL_SSL_CA_CRT_FILENAME},g" /etc/dovecot/conf.d/10-ssl.conf

	if [ "${MMC_MAIL_REPLICATION,,}" == "true" ]; then
			/container/service/dovecot/assets/config/enable-config replication
	fi

  touch $FIRST_START_DONE
fi

exit 0
