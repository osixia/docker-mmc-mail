#!/bin/bash -e

# set -x (bash debug) if log level is trace
# https://github.com/osixia/docker-light-baseimage/blob/stable/image/tool/log-helper
log-helper level eq trace && set -x

command_directory=`postconf -h command_directory`
daemon_directory=`$command_directory/postconf -h daemon_directory`

# make consistency check
$command_directory/postfix check 2>&1

# run Postfix
exec $daemon_directory/master 2>&1
