#!/bin/bash -e
# this script is run during the image build

# clamav-milter
ln -s -f /container/service/clamav-milter/assets/clamav-milter.conf /etc/clamav/clamav-milter.conf
