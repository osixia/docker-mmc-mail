#!/bin/bash -e
sv start clamav || exit 1

sleep 30

exec /usr/sbin/clamav-milter
