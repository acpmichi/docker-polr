#!/bin/sh

cd /src
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

if [ ! -f "database/seeds/AdminSeeder.php" ]; then
    envsubst < "AdminSeeder_withoutEnv.php" > "database/seeds/AdminSeeder.php"
	rm -f AdminSeeder_withoutEnv.php
fi
php artisan db:seed --class=AdminSeeder --force

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
