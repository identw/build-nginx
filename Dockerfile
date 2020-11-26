ARG ubuntu_version='20.04'
FROM ubuntu:${ubuntu_version}
ENV DEBIAN_FRONTEND noninteractive
ARG ubuntu_codename='focal'

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

ARG custom_ssl=false
ARG openssl_version="1.1.1f"
ARG openssl="openssl-${openssl_version}"
ARG openssl_url="https://www.openssl.org/source/old/${openssl_version}/${openssl}.tar.gz"
ARG nginx_version="1.18.0"
ARG nginx_deb_version="${nginx_version}-2~${ubuntu_codename}"
WORKDIR /root
RUN apt-get source nginx=${nginx_deb_version} && \
    sed -i "s@--with-stream_ssl_preread_module@--with-stream_ssl_preread_module --add-module=/root/modules/nginx-module-vts-${vts_version}@" ./nginx-${nginx_version}/debian/rules

RUN if [ ${custom_ssl} = 'true' ]; then \
        cd /root && \
        wget ${openssl_url} && \
        gzip -d ${openssl}.tar.gz -c | tar -x && \
        sed -i "s@./configure --prefix@./configure --with-openssl=/root/${openssl} --with-openssl-opt='no-ssl2 no-ssl3 -fPIC' --prefix@g" ./nginx-${nginx_version}/debian/rules; \
    fi;

WORKDIR /root/nginx-${nginx_version}
