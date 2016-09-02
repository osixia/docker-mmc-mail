#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

mkdir -p ${CONTAINER_SERVICE_DIR}/opendkim/assets/keys

touch ${CONTAINER_SERVICE_DIR}/opendkim/assets/config/KeyTable
touch ${CONTAINER_SERVICE_DIR}/opendkim/assets/config/SigningTable

ln -sf ${CONTAINER_SERVICE_DIR}/opendkim/assets/config/opendkim.conf /etc/opendkim.conf
ln -sf ${CONTAINER_SERVICE_DIR}/opendkim/assets/config/TrustedHosts /etc/opendkim/TrustedHosts
ln -sf ${CONTAINER_SERVICE_DIR}/opendkim/assets/config/KeyTable /etc/opendkim/KeyTable
ln -sf ${CONTAINER_SERVICE_DIR}/opendkim/assets/config/SigningTable /etc/opendkim/SigningTable

FIRST_START_DONE="${CONTAINER_STATE_DIR}/docker-opendkim-first-start-done"
# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  echo "$HOSTNAME" >> /etc/opendkim/TrustedHosts
  [[ -n "$MMC_MAIL_REPLICATION_LOCAL_NAME" ]] && echo "$MMC_MAIL_REPLICATION_LOCAL_NAME" >> /etc/opendkim/TrustedHosts
  [[ -n "$MMC_MAIL_REPLICATION_HOST" ]] && echo "$MMC_MAIL_REPLICATION_HOST" >> /etc/opendkim/TrustedHosts

  # list mail domains
  LDAP_AUTH=""
  if [ -n "${MMC_MAIL_LDAP_BIND_DN}" ]; then
    LDAP_AUTH="-D ${MMC_MAIL_LDAP_BIND_DN}"
  fi
  if [ -n "${MMC_MAIL_LDAP_BIND_PW}" ]; then
    LDAP_AUTH="$LDAP_AUTH -w ${MMC_MAIL_LDAP_BIND_PW}"
  fi

  if [ "${MMC_MAIL_LDAP_CLIENT_TLS,,}" == "true" ]; then
    LDAP_AUTH="$LDAP_AUTH -ZZ"
  fi

  # better way ?
  HOST_FILE="ldap-hosts"
  touch $HOST_FILE

  /sbin/setuser root ldapsearch -x -H ${MMC_MAIL_LDAP_URL} -b ${MMC_MAIL_LDAP_BASE_DN} "(&(objectClass=mailDomain)(virtualdomain=*))" ${LDAP_AUTH} | grep "virtualdomain:" > ${HOST_FILE}
  sed -i --follow-symlinks "s/virtualdomain: //g" $HOST_FILE

  for domain in $(cat $HOST_FILE);
  do

    log-helper info "Domain: $domain"

    # the domain private key doesn't exists -> generate one
    if [ ! -f "${CONTAINER_SERVICE_DIR}/opendkim/assets/keys/$domain.key" ]; then

      log-helper info "-> key not found, generating one"
      opendkim-genkey --domain=$domain --append-domain --selector=$MMC_MAIL_OPENDKIM_SELECTOR --directory ${CONTAINER_SERVICE_DIR}/opendkim/assets/keys

      log-helper info "-> add the following DNS entry:"
      cat ${CONTAINER_SERVICE_DIR}/opendkim/assets/keys/mail.txt

      mv ${CONTAINER_SERVICE_DIR}/opendkim/assets/keys/mail.private ${CONTAINER_SERVICE_DIR}/opendkim/assets/keys/$domain.key
      mv ${CONTAINER_SERVICE_DIR}/opendkim/assets/keys/mail.txt ${CONTAINER_SERVICE_DIR}/opendkim/assets/keys/$domain.txt
    fi

    echo "$MMC_MAIL_OPENDKIM_SELECTOR._domainkey.$domain. $domain:$MMC_MAIL_OPENDKIM_SELECTOR:${CONTAINER_SERVICE_DIR}/opendkim/assets/keys/$domain.key" >> /etc/opendkim/KeyTable
    echo "*@$domain $MMC_MAIL_OPENDKIM_SELECTOR._domainkey.$domain." >> /etc/opendkim/SigningTable
    echo "$domain" >> /etc/opendkim/TrustedHosts
    echo "*.$domain" >> /etc/opendkim/TrustedHosts

  done

  rm -f $HOST_FILE

  touch $FIRST_START_DONE
fi

chmod 755 ${CONTAINER_SERVICE_DIR}/opendkim/assets/keys
chmod 600 ${CONTAINER_SERVICE_DIR}/opendkim/assets/keys/*
chown opendkim:opendkim -R ${CONTAINER_SERVICE_DIR}/opendkim/assets/keys
chown opendkim:opendkim -R /etc/opendkim
chown opendkim:opendkim -R /etc/opendkim.conf

exit 0
