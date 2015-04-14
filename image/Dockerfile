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
	clamav-milter

# Add install script and phpMyAdmin assets
ADD service/install.sh /tmp/install.sh
ADD service/phpmyadmin/assets /osixia/phpmyadmin

# Run install script and clean all
RUN ./tmp/install.sh \
	&& rm phpmyadmin.tar.gz \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add default env variables
ADD env.yml /etc/env.yml

# Add phpMyAdmin container start config
ADD service/phpmyadmin/container-start.sh /etc/my_init.d/phpmyadmin

# Set wordpress data directory in a data volume
VOLUME ["/var/www/phpmyadmin"]

# Expose http and https default ports
EXPOSE 80 443