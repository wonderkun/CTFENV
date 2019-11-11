#!/bin/bash

set -xe 

cp -r /usr/src/php /var/www/html/

apachectl  -X
sleep infinity