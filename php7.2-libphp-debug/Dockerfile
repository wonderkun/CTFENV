FROM php:7.2.24-apache

# 1. 安装xdebug,支持远程调试，调试端口一般是 9000

RUN set -xe \
    && sed  -i "s/deb.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list  \
    && sed  -i "s/security.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list  \
    && apt-get update  \
    && apt-get install -y wget nginx libcurl4-gnutls-dev libxml2-dev libssl-dev zlib1g-dev libedit-dev  libsodium-dev libargon2-dev gdb git libsqlite3-dev procps apache2-dev unzip
    
# rebuild libphp

RUN set -xe \
    && docker-php-source extract  \
    && cd /usr/src/php \
    && ./configure $(php-config --configure-options) \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-debug \
    --enable-phpdbg \
    CFLAGS='-fstack-protector-strong -fpic -fpie -O0 -g' \
    LDFLAGS='-Wl,-O1 -Wl,--hash-style=both -pie' \
    CPPFLAGS='-fstack-protector-strong -fpic -fpie -O0 -g' \
    && make \
    && make install 

RUN set -xe \ 
    && cd /root/  \
    # && wget -O pwndbg.zip https://github.com/pwndbg/pwndbg/archive/dev.zip  \
    # && unzip pwndbg.zip \
    && git clone https://github.com/pwndbg/pwndbg.git \
    && cd pwndbg \
    && ./setup.sh \
    && echo 'export LC_CTYPE=C.UTF-8' >> /root/.bashrc 

RUN mkdir /extension
COPY ./extension/test /extension/test

COPY ./config/start.sh /start.sh 
COPY ./config/php.ini /usr/local/etc/php/php.ini

RUN set -xe \
    &&  cd /extension/test \
    &&  phpize \
    && ./configure --with-php-config=/usr/local/bin/php-config \
    && make \
    && make install \
    && make clean \
    && echo "extension=test.so" >> /usr/local/etc/php/php.ini

RUN chmod +x /start.sh 

EXPOSE 80

CMD ["/start.sh"]