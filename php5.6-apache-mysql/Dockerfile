FROM php:5.6-apache

# 1. 安装xdebug,支持远程调试，调试端口一般是 9000

RUN set -xe \
    && sed  -i "s/deb.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list  \
    && sed  -i "s/security.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list  \
    && apt-get update  \
    && apt-get install -y wget

RUN set -xe \
    # 安装扩展
    && docker-php-ext-install -j$(nproc) pcntl \
    && docker-php-ext-install -j$(nproc) posix \
    && docker-php-ext-install -j$(nproc) pdo pdo_mysql \  
    && docker-php-ext-install -j$(nproc) mysql mysqli

# install xdebug 
RUN set -xe \ 
    && cd /tmp \ 
    && wget -O xdebug.tgz https://xdebug.org/files/xdebug-2.5.5.tgz \
    && tar -zxvf xdebug.tgz \
    && cd xdebug* \
    && phpize \
    && ./configure --enable-xdebug --with-php-config=/usr/local/bin/php-config \
    && make \
    && make test \
    && make install \
    && cd /tmp \
    && rm -rf xdebug*
 
# build php.ini 
RUN set -xe \
    && cp /usr/local/etc/php/php.ini-development  /usr/local/etc/php/php.ini \
    && echo "zend_extension=xdebug.so" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.auto_trace=on" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.trace_output_dir='/tmp/'" >> /usr/local/etc/php/php.ini \
    && echo 'xdebug.collect_params=4' >> /usr/local/etc/php/php.ini \
    && echo "xdebug.remote_enable=1" >> /usr/local/etc/php/php.ini  \ 
    && echo 'xdebug.remote_autostart=1' >>  /usr/local/etc/php/php.ini \
    && echo "xdebug.remote_connect_back=0" >> /usr/local/etc/php/php.ini \ 
    # xdebug.remote_host 就会回连地址,mac的docker,主机有一个域名叫  docker.for.mac.localhost 
    && echo 'xdebug.remote_host=docker.for.mac.localhost' >>   /usr/local/etc/php/php.ini \
    && echo "xdebug.max_nesting_level=250" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.collect_return=on" >> /usr/local/etc/php/php.ini 

