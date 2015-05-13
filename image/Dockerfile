FROM osixia/baseimage:0.10.4
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Download, check integrity and unzip phpMyAdmin to /var/www/phpmyadmin_bootstrap
RUN apt-get update && /sbin/enable-service ssl-kit \
	&& LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	postfix postfix-ldap  \
	dovecot-core dovecot-imapd dovecot-lmtpd dovecot-ldap dovecot-sieve dovecot-managesieved \
	opendkim opendkim-tools \
	spamassassin spamc \
	clamav clamav-base clamav-freshclam clamav-daemon clamav-milter \
	arj bzip2 cabextract cpio file gzip lzop nomarch p7zip pax rpm unrar unzip zip zoo

# Add install script and services assets
ADD service/install.sh /tmp/install.sh
ADD service/clamav/assets /osixia/clamav
ADD service/dovecot/assets /osixia/dovecot
ADD service/opendkim/assets /osixia/opendkim
ADD service/postfix/assets /osixia/postfix
ADD service/spamassassin/assets /osixia/spamassassin

# Run install script and clean all
RUN ./tmp/install.sh \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add default env variables
ADD env.yml /etc/env.yml

# Add phpMyAdmin container start config
ADD service/postfix/container-start.sh /etc/my_init.d/01-postfix
ADD service/dovecot/container-start.sh /etc/my_init.d/02-dovecot
#ADD service/opendkim/container-start.sh /etc/my_init.d/03-opendkim

ADD service/clamav/daemon.sh /etc/service/clamav/run
ADD service/clamav/daemon2.sh /etc/service/clamav-milter/run
ADD service/opendkim/daemon.sh /etc/service/opendkim/run
ADD service/spamassassin/daemon.sh /etc/service/spamassassin/run

# Set wordpress data directory in a data volume
VOLUME ["/var/mail"]

# Expose imap and smtp ports
EXPOSE 143 587
