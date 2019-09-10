#!/bin/bash

service nginx start 
php-fpm -D

chown www-data:www-data /var/run/php-fpm.sock

sleep infinity