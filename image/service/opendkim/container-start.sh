#!/bin/bash -e

ldapsearch -x -h $LDAP_URL -b $LDAP_BASE_DN "(&(objectClass=mailDomain)(virtualdomain=*))"
