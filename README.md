# About
For build nginx with custom openssl libs for Ubuntu

# Build

https://wiki.debian.org/BuildingTutorial - how to build packages with Debian/Ubuntu

```
docker build -t build-nginx ./
docker run -t -i --rm build-nginx /bin/bash
debuild -b -uc -us
```
