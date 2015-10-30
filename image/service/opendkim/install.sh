#!/bin/bash -e
# this script is run during the image build

# opendkim
mkdir -p /container/service/opendkim/assets/keys
mkdir -p /etc/opendkim
ln -s -f /container/service/opendkim/assets/config/opendkim.conf /etc/opendkim.conf
ln -s /container/service/opendkim/assets/config/TrustedHosts /etc/opendkim/TrustedHosts

echo "SOCKET=\"inet:12301@127.0.0.1\"" >> /etc/default/opendkim
