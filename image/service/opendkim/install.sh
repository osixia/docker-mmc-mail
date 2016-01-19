#!/bin/bash -e
# this script is run during the image build

# opendkim
mkdir -p /etc/opendkim

echo "SOCKET=\"inet:12301@127.0.0.1\"" >> /etc/default/opendkim
