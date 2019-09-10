#!/bin/bash


set -xe 

cd test \
&&  phpize \
&& ./configure --enable-test --with-php-config=/usr/local/bin/php-config \
&& make \
&& make install \
&& echo "extension=test.so" >> /usr/local/etc/php/php.ini