FROM php:5.6-cli

# 1. 安装xdebug,支持远程调试，调试端口一般是 9000

RUN set -xe \
    && sed  -i "s/deb.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list  \
    && sed  -i "s/security.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list  \
    && apt-get update  \
    && apt-get install -y wget libcurl4-gnutls-dev libxml2-dev zlib1g-dev libedit-dev  libsodium-dev  libmcrypt-dev libjpeg-dev libpng-dev libfreetype6-dev gdb git

# php5.6 not support openssl1.1, so I have to install 1.0 by handle 
RUN set -xe \
    && cd /tmp/ \ 
    && wget https://www.openssl.org/source/old/1.0.2/openssl-1.0.2l.tar.gz \
    # && apt-get purge -y openssl \
    && tar zxvf openssl-1.0.2l.tar.gz \ 
    && cd openssl-1.0.2l \
    && ./config -fPIC shared --prefix=/usr/local --openssldir=/usr/local/openssl  \ 
    && make \ 
    && make install \
    && export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig \
    && rm -rf /tmp/openssl* 

RUN set -xe \
    && docker-php-source extract  \
    && cd /usr/src/php \
    && ./configure \
    --build=x86_64-linux-gnu  \
    --with-config-file-path=/usr/local/etc/php  \
    --with-config-file-scan-dir=/usr/local/etc/php/conf.d  \
    --enable-option-checking=fatal  \
    --with-mhash \
    --enable-ftp  \
    --enable-mbstring  \
    --enable-mysqlnd   \
    --with-curl     \
    --with-libedit  \
    --with-openssl \
    --with-zlib  \
    --with-libdir=lib/x86_64-linux-gnu  \
    build_alias=x86_64-linux-gnu  \
    CFLAGS='-fstack-protector-strong -fpic -fpie -O0 -g' \
    LDFLAGS='-Wl,-O1 -Wl,--hash-style=both -pie' \
    CPPFLAGS='-fstack-protector-strong -fpic -fpie -O0 -g' \
    --enable-debug \
    --enable-phpdbg \
    && make \
    && make install 

RUN set -xe \ 
    && apt install -y zip \
    && cd /root/  \
    # && wget -O pwndbg.zip https://github.com/pwndbg/pwndbg/archive/dev.zip  \
    # && unzip pwndbg.zip \
    && git clone https://github.com/pwndbg/pwndbg.git \
    && cd pwndbg \
    && ./setup.sh

RUN mkdir /extension \ 
    && echo 'export LC_CTYPE=C.UTF-8' >> /root/.bashrc

WORKDIR /extension
# build php.ini 
RUN set -xe \
    && cp /usr/local/etc/php/php.ini-development  /usr/local/etc/php/php.ini 


CMD ["tail","-f","/dev/null"]