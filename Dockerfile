ARG ubuntu_version='16.04'
FROM ubuntu:${ubuntu_version}
ENV DEBIAN_FRONTEND noninteractive
ARG ubuntu_codename='xenial'

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
        git \
        wget

RUN cd /etc/apt/sources.list.d/ && \
    echo "deb http://nginx.org/packages/ubuntu/ ${ubuntu_codename} nginx" >> nginx.list && \
    echo "deb-src http://nginx.org/packages/ubuntu/ ${ubuntu_codename} nginx" >> nginx.list && \
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add - && \
    apt-get update

RUN apt-get build-dep nginx -y

ARG vts_version='v0.1.18'
RUN mkdir /root/modules && \
    cd /root/modules && \
    git clone https://github.com/vozlt/nginx-module-vts.git && \
    mv nginx-module-vts nginx-module-vts-${vts_version} && \
    cd nginx-module-vts-${vts_version} && \
    git checkout ${vts_version}


ARG brotli_version='e505dce'
RUN cd /root/modules && \
    git clone https://github.com/google/ngx_brotli && \
    mv ngx_brotli nginx-module-brotli-${brotli_version} && \
    cd nginx-module-brotli-${brotli_version}&& \
    git submodule update --init &&\
    git checkout ${brotli_version}

ARG openssl="openssl-1.0.2g"
ARG openssl_url="https://www.openssl.org/source/old/1.0.2/${openssl}.tar.gz"
ARG nginx_version="1.16.1"
ARG nginx_deb_version="1~${ubuntu_codename}"
RUN cd /root && \
    wget ${openssl_url} && \
    gzip -d ${openssl}.tar.gz -c | tar -x && \
    apt-get source nginx=${nginx_version}-${nginx_deb_version} && \
    sed -i "s@./configure --prefix@./configure --with-openssl=/root/${openssl} --with-openssl-opt='no-ssl2 no-ssl3 -fPIC' --prefix@g;s@--with-stream_ssl_preread_module@--with-stream_ssl_preread_module --add-module=/root/modules/nginx-module-vts-${vts_version} --add-module=/root/modules/nginx-module-brotli-${brotli_version}@" ./nginx-${nginx_version}/debian/rules

WORKDIR /root/nginx-${nginx_version}
