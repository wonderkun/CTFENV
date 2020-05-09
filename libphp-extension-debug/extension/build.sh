#!/bin/bash


set -xe 

cd /extension/test \
&&  phpize \
&& ./configure --with-php-config=/usr/local/bin/php-config \
&& make \
&& make install \
&& make clean \
&& echo "extension=test.so" >> /usr/local/etc/php/php.ini