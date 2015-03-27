#!/bin/bash 
 
MAILDIRS="/home/vmail/" 
DB_PATH="/var/lib/amavis/.spamassassin/" 
DB_USER="amavis" 
DB_GROUP="amavis" 
SA_LEARN="`which sa-learn`" 
LEARN_SPAM_CMD="$SA_LEARN --spam --no-sync --dbpath $DB_PATH" 
LEARN_HAM_CMD="$SA_LEARN --ham --no-sync --dbpath $DB_PATH" 
 
# Learn SPAM 
find $MAILDIRS -iregex '.*/\.Junk\(/.*\)?\/\(cur\|new\)/.*' -type f -exec $LEARN_SPAM_CMD {} \; 
chown -R $DB_USER:$DB_GROUP $DB_PATH 
 
# Learn HAM 
find $MAILDIRS -iregex '.*/cur/.*' -not -regex '.*/\.Junk\(/.*\)?\/\(cur\|new\)/.*' -type f  -exec $LEARN_HAM_CMD {} \; 
chown -R $DB_USER:$DB_GROUP $DB_PATH 
 
# Clean SPAM folders 
find $MAILDIRS -iregex '.*/\.Junk\(/.*\)?\/\(cur\|new\)/.*' -type f -ctime +30 -delete
