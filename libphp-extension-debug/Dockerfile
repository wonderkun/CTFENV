FROM ubuntu:18.04

ARG PROXY
ARG BRANCH

RUN set -xe \
    && sed  -i "s/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list  \
    && sed  -i "s/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list  \
    && apt-get update \
    && apt-get install -y apache2 apache2-dev wget libcurl4-gnutls-dev libxml2-dev libssl-dev zlib1g-dev libedit-dev  libsodium-dev gdb git git libsqlite3-dev procps unzip bison re2c libonig-dev 

WORKDIR /root/

# fufufufufufck gfw
RUN set -xe \ 
    && git config --global http.proxy $PROXY \
    && git config --global https.proxy $PROXY \
    && git clone https://github.com/php/php-src.git \
    && cd php-src \ 
    && git checkout $BRANCH \
    && ./buildconf \
    && ./configure  --build=x86_64-linux-gnu --with-config-file-path=/usr/local/etc/php --with-config-file-scan-dir=/usr/local/etc/php/conf.d --enable-option-checking=fatal --with-mhash --enable-ftp --enable-mbstring --enable-mysqlnd --with-sodium=shared --with-pdo-sqlite=/usr --with-sqlite3=/usr --with-curl --with-libedit --with-openssl --with-zlib --with-libdir=lib/x86_64-linux-gnu --with-apxs2 --disable-cgi build_alias=x86_64-linux-gnu --enable-sysvsem --enable-sysvshm --enable-debug --enable-phpdbg  \
    CFLAGS='-fstack-protector-strong -fpic -fpie -O0 -g' \
    LDFLAGS='-Wl,-O1 -Wl,--hash-style=both -pie' \
    CPPFLAGS='-fstack-protector-strong -fpic -fpie -O0 -g' \   
    && make \
    && make install \
    && make clean \
    && rm -rf .git
     
# disable  mpm_event and enable mpm_prefork , because php not support  mpm_event 
# https://www.php.net/manual/en/install.unix.apache2.php

RUN set -xe \ 
    && a2dismod mpm_event \
    && a2enmod  mpm_prefork \ 
    && mkdir /usr/local/etc/php \ 
    && mkdir /usr/local/etc/php/conf.d
    # && a2dismod 

# RUN set -xe \ 
#     && cd /root/  \
#     # && wget -O pwndbg.zip https://github.com/pwndbg/pwndbg/archive/dev.zip  \
#     # && unzip pwndbg.zip \
#     && git clone https://github.com/pwndbg/pwndbg.git \
#     && cd pwndbg \
#     && ./setup.sh \
#     && echo 'export LC_CTYPE=C.UTF-8' >> /root/.bashrc 

RUN set -xe \
    && git clone https://github.com/longld/peda.git   ~/peda \
    && git clone https://github.com/scwuaptx/Pwngdb.git  ~/Pwngdb \ 
    && cp ~/Pwngdb/.gdbinit ~/

COPY ./config/apache2.conf /etc/apache2/sites-available/000-default.conf

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