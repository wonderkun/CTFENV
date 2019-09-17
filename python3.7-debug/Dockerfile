FROM python:3.7.4-slim

RUN set -xe \
    && sed  -i "s/deb.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list  \
    && sed  -i "s/security.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list  \
    && apt-get update 

COPY ./start.sh /start.sh

RUN set -xe \ 
    && pip install -U pip \
    && pip install -U ptvsd \
    && pip install  virtualenv \ 
    && mkdir /Debug \
    && chmod +x /start.sh

WORKDIR /Debug

EXPOSE 3000

CMD ["/start.sh"]

