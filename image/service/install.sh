#!/bin/bash -e
# this script is run during the image build

groupadd -g 5000 vmail && useradd -g vmail -u 5000 vmail -d /var/mail

# backup default config files
cp /etc/postfix/main.cf /etc/postfix/main.cf.bak
cp /etc/postfix/master.cf /etc/postfix/master.cf.bak

#opendkim
cp /osixia/opendkim/config/opendkim.conf /etc/opendkim.conf
echo "SOCKET=\"inet:12301@localhost\"" >> /etc/default/opendkim
mkdir -p /etc/opendkim/keys
