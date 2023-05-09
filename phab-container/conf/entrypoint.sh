#!/bin/bash

set -e
#set -x

installdir=$INSTALLDIR
host=$HOST
port=$PORT

if [ "$PORT" = "80" ]; then
    base_uri=http://$host
else
    base_uri=http://$host:$port
fi

cp /opt/phabdev/local.json $installdir/conf/local/

escaped_base_uri=$(printf '%s\n' "$base_uri" | sed -e 's/[\/&]/\\&/g')
sed -i 's/BASE_URI/'${escaped_base_uri}'/g' $installdir/conf/local/local.json
escaped_host=$(printf '%s\n' "$host" | sed -e 's/[\/&]/\\&/g')
sed -i 's/HOST/'${escaped_host}'/g' $installdir/conf/local/local.json

npm --prefix $installdir/support/aphlict/server --silent install ws
(exec $installdir/bin/aphlict start --config $installdir/conf/aphlict/aphlict.default.json) &

escaped_installdir=$(printf '%s\n' "$INSTALLDIR" | sed -e 's/[\/&]/\\&/g')
sudo sed -i 's/PHABDEV_HOST/'${HOST}'/g' /etc/nginx/conf.d/phab.conf
sudo sed -i 's/PHABDEV_INSTALLDIR/'${escaped_installdir}'/g' /etc/nginx/conf.d/phab.conf

# Wait for mysql
while ! nc -z phabdev-db 3306 2>/dev/null
do
	sleep 0.1
done

mariadb --host=phabdev-db --user=root --password=phabricator_secret --execute="GRANT ALL PRIVILEGES ON *.* TO 'phabricator'@'%' IDENTIFIED BY 'phabricator' WITH GRANT OPTION;"

$installdir/bin/storage upgrade --force

sudo -u phab-phd $installdir/bin/phd start

sudo php-fpm${PHPVER} --daemonize

echo "Remember to update /etc/hosts to include:"
echo -e "    127.0.0.1 $host \t\t# For accessing from your browser "
echo -e "    127.0.0.1 phabdev-db \t\t# For unit tests to access the database "
echo "Starting web server on $base_uri ..."
exec sudo nginx

