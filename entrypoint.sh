#!/bin/sh

chown -R $USER:www-data /var/www/html/src

cd src && composer install && cd ..
npm install
npm run build
