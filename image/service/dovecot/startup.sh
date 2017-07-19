#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

# dovecot
ln -sf ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/dovecot.conf /etc/dovecot/dovecot.conf
ln -sf ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/dovecot-ldap.conf.ext /etc/dovecot/dovecot-ldap.conf.ext
ln -sf ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/dovecot-trash.conf.ext /etc/dovecot/dovecot-trash.conf.ext
ln -sf ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/conf.d/* /etc/dovecot/conf.d

FIRST_START_DONE="${CONTAINER_STATE_DIR}/docker-dovecot-first-start-done"
# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

	# ldap
	sed -i "s|{{ MMC_MAIL_LDAP_URL }}|${MMC_MAIL_LDAP_URL}|g" ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/dovecot-ldap.conf.ext
	sed -i "s|{{ MMC_MAIL_LDAP_BASE_DN }}|${MMC_MAIL_LDAP_BASE_DN}|g" ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/dovecot-ldap.conf.ext

	# ldap bind dn
	if [ -n "${MMC_MAIL_LDAP_BIND_DN}" ]; then
	  echo "dn = $MMC_MAIL_LDAP_BIND_DN" >> ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/dovecot-ldap.conf.ext

		# 	ldap bind password
	  if [ -n "${MMC_MAIL_LDAP_BIND_PW}" ]; then
	    echo "dnpass = $MMC_MAIL_LDAP_BIND_PW" >> ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/dovecot-ldap.conf.ext
	  fi
	fi

	# ldap tls config
	if [ "${MMC_MAIL_LDAP_CLIENT_TLS,,}" == "true" ]; then

		echo "tls = yes" >> ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/dovecot-ldap.conf.ext
		echo "tls_require_cert = $MMC_MAIL_LDAP_CLIENT_TLS_REQCERT" >> ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/dovecot-ldap.conf.ext
		echo "tls_ca_cert_file = ${CONTAINER_SERVICE_DIR}/dovecot/assets/ldap-client/certs/$MMC_MAIL_LDAP_CLIENT_TLS_CA_CRT_FILENAME" >> ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/dovecot-ldap.conf.ext
		echo "tls_cert_file = ${CONTAINER_SERVICE_DIR}/dovecot/assets/ldap-client/certs/$MMC_MAIL_LDAP_CLIENT_TLS_CRT_FILENAME" >> ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/dovecot-ldap.conf.ext
		echo "tls_key_file = ${CONTAINER_SERVICE_DIR}/dovecot/assets/ldap-client/certs/$MMC_MAIL_LDAP_CLIENT_TLS_KEY_FILENAME" >> ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/dovecot-ldap.conf.ext
	fi

	MMC_MAIL_SSL_CRT_PATH="${CONTAINER_SERVICE_DIR}/postfix/assets/certs/${MMC_MAIL_SSL_CRT_FILENAME}"
	MMC_MAIL_SSL_KEY_PATH="${CONTAINER_SERVICE_DIR}/postfix/assets/certs/${MMC_MAIL_SSL_KEY_FILENAME}"

	# ssl
	sed -i "s|{{ HOSTNAME }}|${HOSTNAME}|g" ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/conf.d/11-ssl-local-name.conf
	sed -i "s|{{ MMC_MAIL_SSL_CRT_PATH }}|${MMC_MAIL_SSL_CRT_PATH}|g" ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/conf.d/11-ssl-local-name.conf
  sed -i "s|{{ MMC_MAIL_SSL_KEY_PATH }}|${MMC_MAIL_SSL_KEY_PATH}|g" ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/conf.d/11-ssl-local-name.conf

  touch $FIRST_START_DONE
fi

if [ "${MMC_MAIL_REPLICATION,,}" == "true" ]; then
		${CONTAINER_SERVICE_DIR}/dovecot/assets/config/enable-config replication
fi

[ -f /etc/dovecot/dovecot-ldap-userdb.conf.ext ] && rm -f /etc/dovecot/dovecot-ldap-userdb.conf.ext
ln -sf ${CONTAINER_SERVICE_DIR}/dovecot/assets/config/dovecot-ldap.conf.ext /etc/dovecot/dovecot-ldap-userdb.conf.ext

exit 0
