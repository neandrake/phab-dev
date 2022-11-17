#!/bin/bash

installdir=/var/www/phabricator

# The install directory is mapped to a local folder. Only copy this default config
# over if there isn't one already, otherwise use the one that's there.
if [[ ! -f "$installdir/conf/local.json" ]]; then
	mv /opt/phabdev/local.json $installdir/conf/local/
fi

# Wait for mysql
while ! nc -z phabdev-db 3306 2>/dev/null
do
	sleep 0.1
done

mariadb --host=phabdev-db --user=root --password=phabricator_secret --execute="GRANT ALL PRIVILEGES ON *.* TO 'phabricator'@'%' IDENTIFIED BY 'phabricator' WITH GRANT OPTION;"

$installdir/bin/storage upgrade --force

sudo -u phab-phd $installdir/bin/phd start

sudo php-fpm7.4 --daemonize

echo "Starting web server on http://localhost:8080 ..."
exec sudo nginx

