FROM ubuntu:16.04
ENV DEBIAN_FRONTEND noninteractive
ARG openssl="openssl-1.0.1f"
ARG openssl_url="https://www.openssl.org/source/old/1.0.1/${openssl}.tar.gz"
ARG nginx_version="1.12.1"
ARG nginx_deb_version="1~xenial"
# Set user for build cocos

## Set locale
#RUN sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen && \
#    locale-gen && \
#    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# For jenkins slave
RUN apt-get update && \
    apt-get install -y \
        dpkg-dev \
        devscripts \
        build-essential \
        fakeroot \
        debhelper \
        libssl-dev \
        libpcre3-dev \
        zlib1g-dev \
        quilt \
        vim \
        curl \
        wget

RUN cd /etc/apt/sources.list.d/ && \
    echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" >> nginx.list && \
    echo "deb-src http://nginx.org/packages/ubuntu/ xenial nginx" >> nginx.list && \
    curl https://nginx.ru/keys/nginx_signing.key | apt-key add - && \
    apt-get update


RUN cd /root && \
    wget ${openssl_url} && \
    gzip -d ${openssl}.tar.gz -c | tar -x && \
    apt-get source nginx=${nginx_version}-${nginx_deb_version} && \
    sed -i "s@./configure --prefix@./configure --with-openssl=/root/${openssl} --with-openssl-opt='no-ssl2 no-ssl3 -fPIC' --prefix@g" ./nginx-${nginx_version}/debian/rules

WORKDIR /root/nginx-${nginx_version}
