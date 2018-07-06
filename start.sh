#!/bin/sh

function doSeStartThing
{
echo "Am Anfang vom Try"
if [ ! -f ".env" ]; then
    POLR_GENERATED_AT=`date +"%B %d, %Y"`
    export POLR_GENERATED_AT

    APP_KEY=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
    export APP_KEY

    envsubst < ".env_polr" > ".env"

    php artisan migrate:install
    php artisan migrate --force
    composer dump-autoload
    php artisan geoip:update
fi

cd database/
cd seeds/

if [ ! -f "AdminSeeder.php" ]; then
    echo "im AdminSeeder IF"
	envsubst < "AdminSeeder_withoutEnv.php" > "AdminSeeder.php"
	rm -f AdminSeeder_withoutEnv.php
	php artisan db:seed --class=AdminSeeder --force
fi
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
echo "Am Ende vom Try"
}

function fallsError
{
  echo "Am Anfang vom Catch"
  cd /src
  php artisan migrate --force
  composer dump-autoload
  php artisan geoip:update
  php artisan db:seed --class=AdminSeeder --force
  echo "Am Ende vom Catch"
}

function execTheThing
{
  doSeStartThing || fallsError
}

sleep 10
cd /src
execTheThing