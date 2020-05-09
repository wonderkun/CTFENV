#!/bin/bash

set -xe 

cp -r  ~/php-src /var/www/html/

apachectl  -X
sleep infinity