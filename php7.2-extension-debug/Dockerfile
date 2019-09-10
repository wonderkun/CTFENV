FROM php:7.2-cli

# 1. 安装xdebug,支持远程调试，调试端口一般是 9000

RUN set -xe \
    && sed  -i "s/deb.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list  \
    && sed  -i "s/security.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list  \
    && apt-get update  \
    && apt-get install -y wget libcurl4-gnutls-dev libxml2-dev libssl-dev zlib1g-dev libedit-dev  libsodium-dev libargon2-dev gdb git

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
    && ./setup.sh

RUN mkdir /extension \ 
    && echo 'export LC_CTYPE=C.UTF-8' >> /root/.bashrc

WORKDIR /extension
# build php.ini 
RUN set -xe \
    && cp /usr/local/etc/php/php.ini-development  /usr/local/etc/php/php.ini 

CMD ["tail","-f","/dev/null"]