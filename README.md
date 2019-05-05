# About
For build nginx  for Ubuntu  with another openssl libs and additional module https://github.com/vozlt/nginx-module-vts.

Default: with vts 0.1.18, openssl 1.0.1u, nginx 1.14.2 for ubuntu 16.04

# Build

https://wiki.debian.org/BuildingTutorial - how to build packages with Debian/Ubuntu

```bash
docker build -t build-nginx ./
docker run -t -i --rm build-nginx /bin/bash
debuild -b -uc -us
```

For change nginx version use build-args. For Example:
```bash
docker build --build-arg nginx_version=1.14.2 -t build-nginx ./
docker run -t -i --rm build-nginx /bin/bash
debuild -b -uc -us
```

For change openssl version use build-args. For Example:
```bash
docker build --build-arg nginx_version=1.14.1 --build-arg openssl=openssl-1.0.1t -t build-nginx ./
docker run -t -i --rm build-nginx /bin/bash
debuild -b -uc -us
```

For change ubuntu version
```bash
docker build --build-arg ubuntu_codename=bionic --build-arg ubuntu_version=18.04 -t build-nginx ./
docker run -t -i --rm build-nginx /bin/bash
debuild -b -uc -us
```

deb packages will be create in the `/root/` dir.
