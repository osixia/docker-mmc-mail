FROM osixia/baseimage:0.10.0
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.net>

# Default configuration: can be overridden at the docker command line
ENV DOMAIN_NAME example.com

ENV LDAP_HOST 127.0.0.1
ENV LDAP_PORT 389
ENV LDAP_BASE_DN dc=example,dc=com

# SSL filename
ENV SMTP_SSL_CRT_FILENAME smtp.crt
ENV SMTP_SSL_KEY_FILENAME smtp.key
ENV IMAP_SSL_CRT_FILENAME imap.crt
ENV IMAP_SSL_KEY_FILENAME imap.key

# Disable SSH
# RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Enable ca-authority
RUN /sbin/enable-service ca-authority

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Add multiverse repository 
RUN sed -i -e "s_deb http://archive.ubuntu.com/ubuntu/ trusty main restricted_deb http://archive.ubuntu.com/ubuntu/ trusty main restricted multiverse_g" /etc/apt/sources.list

# Add Mandriva MDS repository
RUN echo "deb http://mds.mandriva.org/pub/mds/debian wheezy main" >> /etc/apt/sources.list

# Resynchronize the package index files from their sources
RUN apt-get -y update

# Install phpMyAdmin
RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes --no-install-recommends dovecot-imapd dovecot-ldap dovecot-sieve dovecot-managesieved postfix postfix-ldap python-mmc-mail amavisd-new libdbd-ldap-perl clamav clamav-daemon gzip bzip2 unzip unrar-free p7zip nomarch ripole cabextract zoo arj spamassassin libnet-dns-perl razor pyzor

# Expose http and https default ports
#EXPOSE 80 443

# Add dovecot config directory and daemon
ADD service/dovecot/assets/config /etc/dovecot/config
ADD service/dovecot/dovecot.sh /etc/service/dovecot/run

# Add postfix config directory and daemon
ADD service/postfix/assets/config /etc/postfix/config

# Add amavis config directory and daemon
ADD service/amavis/assets/config /etc/amavis/config
ADD service/amavis/amavis.sh /etc/service/amavis/run

# Add spamassassin config directory and daemon
ADD service/spamassassin/assets /etc/spamassassin/assets
ADD service/spamassassin/spamassassin.sh /etc/service/spamassassin/run

# Add clamav daemon
ADD service/clamav/clamav.sh /etc/service/clamav/run

# install services
ADD service/install.sh /etc/my_init.d/install.sh

# Clear out the local repository of retrieved package files
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
