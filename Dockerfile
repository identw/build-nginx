ARG ubuntu_version='22.04'
FROM ubuntu:${ubuntu_version}
ENV DEBIAN_FRONTEND noninteractive
ARG ubuntu_codename='jammy'

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
        curl \
        git \
        wget \
        gettext-base

RUN cd /etc/apt/sources.list.d/ && \
    echo "deb http://nginx.org/packages/ubuntu/ ${ubuntu_codename} nginx" >> nginx.list && \
    echo "deb-src http://nginx.org/packages/ubuntu/ ${ubuntu_codename} nginx" >> nginx.list && \
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add - && \
    apt-get update

RUN apt-get build-dep nginx -y

ARG vts_version='v0.2.2'
RUN mkdir /root/modules && \
    cd /root/modules && \
    git clone https://github.com/vozlt/nginx-module-vts.git && \
    mv nginx-module-vts nginx-module-vts-${vts_version} && \
    cd nginx-module-vts-${vts_version} && \
    git checkout ${vts_version}

COPY ./template_changelog ./root/template_changelog
COPY ./version_count ./root/version_count
WORKDIR /root
RUN  \
    export version_count=`cat ./version_count` && \
    export nginx_deb_version=`apt-cache policy nginx | grep "Version table:" -A1 | tail -n1 | awk '{ print $1 }'` && \
    apt-get source nginx=${nginx_deb_version} && \
    nginx_dir=`ls -d ./nginx-*` && \
    echo nginx_dir=${nginx_dir} && \
    sed -i "s@--with-stream_ssl_preread_module@--with-stream_ssl_preread_module --add-module=/root/modules/nginx-module-vts-${vts_version}@" ./${nginx_dir}/debian/rules && \
    export nginx_version="${nginx_deb_version}~vts-${vts_version}~${version_count}" && \
    export date_time="`date -R`" && \
    cat ./template_changelog | envsubst > 1 && \
    cp ./${nginx_dir}/debian/changelog ./changelog1 && \
    cat 1 ./changelog1 > ./${nginx_dir}/debian/changelog && \
    cat 1 ./changelog1 > ./changelog && \
    cat ./changelog

ARG custom_ssl=false
ARG openssl_version="1.1.1f"
ARG openssl="openssl-${openssl_version}"
ARG openssl_url="https://www.openssl.org/source/old/${openssl_version}/${openssl}.tar.gz"
RUN if [ ${custom_ssl} = 'true' ]; then \
        cd /root && \
        wget ${openssl_url} && \
        gzip -d ${openssl}.tar.gz -c | tar -x && \
        sed -i "s@./configure --prefix@./configure --with-openssl=/root/${openssl} --with-openssl-opt='no-ssl2 no-ssl3 -fPIC' --prefix@g" ./nginx-${nginx_version}/debian/rules; \
    fi;

RUN \
    nginx_dir=`ls -d ./nginx-*` && \
    cd ${nginx_dir} && \
    debuild -b -uc -us && \
    cd .. && \
    mkdir package && \
    deb=`ls -1 ./*.deb | grep -v dbg_` && \
    cp ./${deb} ./package/
