#!/bin/bash -e

FIRST_START_DONE="/etc/docker-sieve-first-start-done"

# container first start
if [ ! -e "$FIRST_START_DONE" ]; then

  # sieve
  [[ ! -d /var/mail/sieve/ ]] && mkdir -p /var/mail/sieve/
  ln -fs /container/service/sieve/assets/default.sieve /var/mail/sieve/default.sieve
  chown -R vmail:vmail /var/mail/sieve

  sievec /var/mail/sieve/default.sieve

  touch $FIRST_START_DONE
fi

exit 0
