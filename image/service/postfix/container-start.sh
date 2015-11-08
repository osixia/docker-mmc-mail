#!/bin/bash -e

FIRST_START_DONE="/etc/docker-postfix-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # set mailserver hostname
  sed -i "s|{{ HOSTNAME }}|${HOSTNAME}|g" /etc/postfix/main.cf

  # Mailserver ssl config
  # check certificat and key or create it
  /sbin/ssl-helper "/container/service/postfix/assets/certs/$MMC_MAIL_SSL_CRT_FILENAME" "/container/service/postfix/assets/certs/$MMC_MAIL_SSL_KEY_FILENAME" --ca-crt=/container/service/postfix/assets/certs/$MMC_MAIL_SSL_CA_CRT_FILENAME

  # adapt tls config
  sed -i "s|{{ MMC_MAIL_SSL_CA_CRT_FILENAME }}|${MMC_MAIL_SSL_CA_CRT_FILENAME}|g" /etc/postfix/main.cf
  sed -i "s|{{ MMC_MAIL_SSL_CRT_FILENAME }}|${MMC_MAIL_SSL_CRT_FILENAME}|g" /etc/postfix/main.cf
  sed -i "s|{{ MMC_MAIL_SSL_KEY_FILENAME }}|${MMC_MAIL_SSL_KEY_FILENAME}|g" /etc/postfix/main.cf

  sed -i "s|{{ MMC_MAIL_SSL_CA_DHPARAM_1024 }}|${MMC_MAIL_SSL_CA_DHPARAM_1024}|g" /etc/postfix/main.cf
  sed -i "s|{{ MMC_MAIL_SSL_CA_DHPARAM_512 }}|${MMC_MAIL_SSL_CA_DHPARAM_512}|g" /etc/postfix/main.cf

  # ldap config
  for i in `ls /etc/postfix/ldap-*.cf`;
  do
    sed -i "s|{{ MMC_MAIL_LDAP_URL }}|${MMC_MAIL_LDAP_URL}|g" $i;
    sed -i "s|{{ MMC_MAIL_LDAP_BASE_DN }}|${MMC_MAIL_LDAP_BASE_DN}|g" $i;

    # ldap bind dn
    if [ -n "${MMC_MAIL_LDAP_BIND_DN}" ]; then
      echo "bind = yes" >> $i;
      echo "bind_dn = $MMC_MAIL_LDAP_BIND_DN" >> $i;

      # ldap bind password
      if [ -n "${MMC_MAIL_LDAP_BIND_PW}" ]; then
        echo "bind_pw = $MMC_MAIL_LDAP_BIND_PW" >> $i;
      fi
    fi

    # ldap tls config
    if [ "${MMC_MAIL_LDAP_CLIENT_TLS,,}" == "true" ]; then

      REQCERT="no"

      if [ "${MMC_MAIL_LDAP_CLIENT_TLS_REQCERT,,}" == "demand" ]; then
        REQCERT="yes"
      fi

      echo "start_tls = yes" >> $i;
      echo "tls_require_cert = $REQCERT" >> $i;
      echo "tls_ca_cert_file = /container/service/postfix/assets/ldap-client/certs/$MMC_MAIL_LDAP_CLIENT_TLS_CA_CRT_FILENAME" >> $i;
      echo "tls_cert = /container/service/postfix/assets/ldap-client/certs/$MMC_MAIL_LDAP_CLIENT_TLS_CRT_FILENAME" >> $i;
      echo "tls_key = /container/service/postfix/assets/ldap-client/certs/$MMC_MAIL_LDAP_CLIENT_TLS_KEY_FILENAME" >> $i;
    fi
  done

  # prevent fatal: unknown service: smtp/tcp
  # http://serverfault.com/questions/655116/postfix-fails-to-send-mail-with-fatal-unknown-service-smtp-tcp
  cp -f /etc/services /var/spool/postfix/etc/services

  # copy dns settings to chroot jail
  cp -f /etc/resolv.conf /var/spool/postfix/etc/resolv.conf

  touch $FIRST_START_DONE
fi

# set hosts
echo "127.0.0.1 localhost.localdomain" >> /etc/hosts

# fix files permissions
chown -R vmail:vmail /var/mail
chmod 644 /etc/postfix/*.cf

exit 0
