#!/bin/bash -e

FIRST_START_DONE="/etc/docker-sieve-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  sievec /var/mail/sieve/default.sieve

  touch $FIRST_START_DONE
fi

exit 0
