#!/bin/bash -e
# this script is run during the image build

# forward mail logs to docker log collector
touch /var/log/mail.log
ln -sf /dev/stdout /var/log/mail.log
