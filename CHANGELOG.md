# Changelog

## 1.1.1
  - Allow auth by ldap uid only
  - Add imaps support (port 993)
  - Upgrade baseimage: light-baseimage:1.1.1

## 1.1.0
  - Upgrade baseimage: light-baseimage:1.1.0 (debian stretch)

## 1.0.0
  - Upgrade baseimage: light-baseimage:0.2.6
  - Startup optimised

## 0.1.8
  - Fix opendkim config
  - Upgrade baseimage: light-baseimage:0.2.5
  - Add tls certificates for replication only
  - Add opendmarc

## 0.1.7
  - Upgrade baseimage: light-baseimage:0.2.2

## 0.1.6
  - Upgrade baseimage: light-baseimage:0.2.0
  - Makefile with build no cache

## 0.1.5
  - Fix sieve default script
  - disable uid login, use only mail

## 0.1.4
  - Fix chained certificates validation

## 0.1.3
  - Disable ssl_dh_parameters_length = 2048 due to some bugs in dovecot
  - Change MMC_MAIL_SSL_CA_DHPARAM_1024 to MMC_MAIL_SSL_DHPARAM_1024
  - Change MMC_MAIL_SSL_CA_DHPARAM_512 to MMC_MAIL_SSL_DHPARAM_512

## 0.1.2
  - Use light-baseimage:0.1.5

## 0.1.1
  - Use light-baseimage:0.1.4
  - Add MMC_MAIL_SSL_DHPARAM_1024 and MMC_MAIL_SSL_DHPARAM_512 env variables

## 0.1.0
  - Initial release
