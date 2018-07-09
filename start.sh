#!/bin/sh

function doSeStartThing
{
echo "Am Anfang vom Try"
if [ ! -f ".env" ] ; then
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

echo "Am Ende vom Try"
sleep 30
fallsError
}

function fallsError
{
  cd /src
  echo "Am Anfang vom Catch"
  php artisan migrate --force
  composer dump-autoload
  php artisan geoip:update
  envsubst < "AdminSeeder_withoutEnv.php" > "database/seeds/AdminSeeder.php"
  php artisan db:seed --class=AdminSeeder --force
  /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
  echo "Am Ende vom Catch"
}

function execTheThing
{
  doSeStartThing || fallsError
}

sleep 10
cd /src
execTheThing