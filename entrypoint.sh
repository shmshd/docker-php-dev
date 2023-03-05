#!/bin/sh

chown -R $USER:www-data /var/www/html/src

cd src && composer install && cd ..
crontab -l | { cat; echo "*/5 * * * * php /var/www/html/src/cron.php"; } | crontab -
npm install
npm run build
