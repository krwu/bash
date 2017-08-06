#!/usr/bin/env sh

yum -y install epel-release

yum makecache fast

yum -y install wget curl gcc gcc-c++ make autoconf cmake libtool libtool-libs zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel libevent libevent-devel jemalloc

NGINX_VERSION="1.13.3"
NGINX="nginx-$NGINX_VERSION"
LIBRESSL="libressl-2.6.0"
ZLIB="zlib-1.2.11"
PCRE="pcre-8.41"

function dowload {
    printf "Starting downloading source files...\n"

    if [ ! -f "$NGINX.tar.gz" ]; then
        wget http://nginx.org/download/$NGINX.tar.gz
    fi

    if [ ! -f "$LIBRESSL.tar.gz" ]; then
        wget https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/$LIBRESSL.tar.gz
    fi

    if [ ! -f "$ZLIB.tar.gz" ]; then
        wget https://zlib.net/$ZLIB.tar.gz
    fi

    if [ ! -f "$PCRE.tar.gz" ]; then
        wget https://ftp.pcre.org/pub/pcre/$PCRE.tar.gz
    fi

    printf "Downloading complete."
}

if [ ! -d "./source" ]; then
    mkdir ./source
fi

cd ./source
