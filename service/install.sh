#!/bin/sh


HOSTNAME=${HOSTNAME}

# Create vmail user
adduser --system --ingroup mail --uid 500 vmail

echo "$HOSTNAME" >> /etc/mailname
