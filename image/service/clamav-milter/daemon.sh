#!/bin/bash -e
sv start clamav || exit 1
exec /usr/sbin/clamav-milter
