#!/bin/bash -e
# this script is run during the image build

# postfix
ln -s -f /container/service/postfix/assets/config/* /etc/postfix/
