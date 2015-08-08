#!/bin/bash -e
# this script is run during the image build

# sieve
mkdir /var/mail/sieve/
ln -s /container/service/sieve/assets/default.sieve /var/mail/sieve/default.sieve
chown -R vmail:vmail /var/mail/sieve
