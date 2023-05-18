#!/bin/sh

VCSUSER="wanderer"
ROOT="/var/www/phacility/phabricator"

if [ "$1" != "$VCSUSER" ];
then
  exit 1
fi

exec "$ROOT/bin/ssh-auth" $@

