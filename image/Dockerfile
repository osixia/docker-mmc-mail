FROM osixia/light-baseimage:0.1.0
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# Use baseimage-docker's init system.
CMD ["/osixia/tool/run"]

# Install postfix, dovecot, opendkim, clamav, spamassassin
RUN apt-get update && /sbin/install-multiple-process-stack \
  && /sbin/install-service-available ssl-helper-openssl \
	&& LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	postfix postfix-ldap  \
	dovecot-core dovecot-imapd dovecot-lmtpd dovecot-pop3d dovecot-ldap dovecot-sieve dovecot-managesieved \
	opendkim opendkim-tools ldap-utils\
	spamassassin spamc \
	clamav clamav-base clamav-freshclam clamav-daemon clamav-milter \
	arj bzip2 cabextract cpio file gzip lzop nomarch p7zip pax rpm unrar-free unzip zip zoo \
	&& freshclam  -v

# Add service directory to /osixia/service
ADD service /osixia/service

# Use baseimage install-service script and clean all
RUN ./sbin/install-service && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add default env variables
ADD env.yaml /etc/env.yaml

# Set mails directory in a data volume
VOLUME ["/var/mail"]

# Expose smtp, pop3, imap, smtp (submission) and managesieve ports
EXPOSE 25 110 143 587 4190
