#!/bin/bash

service nginx start 
php-fpm -D
cp -r /usr/src/php /var/www/html/

sleep infinity