FROM osixia/light-baseimage:0.1.5
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# Use baseimage's init system.
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/run
CMD ["/container/tool/run"]

# Add vmail user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -g 5000 vmail && useradd -g vmail -u 5000 vmail -d /var/mail

# Install postfix, dovecot, opendkim, clamav, spamassassin
RUN apt-get update \
    && /container/tool/install-multiple-process-stack \
    && /container/tool/install-service-available ssl-helper-openssl ssl-helper-gnutls \
	  && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	     postfix postfix-ldap  \
	     dovecot-core dovecot-imapd dovecot-lmtpd dovecot-pop3d dovecot-ldap dovecot-sieve dovecot-managesieved \
	     opendkim opendkim-tools ldap-utils\
	     spamassassin spamc \
	     clamav clamav-base clamav-freshclam clamav-daemon clamav-milter \
	     arj bzip2 cabextract cpio file gzip lzop nomarch p7zip pax rpm unrar-free unzip zip zoo \
	  && freshclam  -v

# Add service directory to /container/service
ADD service /container/service

# Use baseimage install-service script and clean all
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/install-service
RUN /container/tool/install-service \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add default env variables
ADD env.yaml /container/environment/env.yaml

# Set mails directory in a data volume
VOLUME ["/var/mail", "/data/backup"]

# Expose smtp, pop3, imap, smtp (submission), managesieve and dovecot replication ports
EXPOSE 25 110 143 587 4190 12345
