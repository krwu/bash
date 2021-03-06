#!/usr/bin/env sh

set -e

yum -y install epel-release

yum makecache fast

yum -y install wget curl gcc gcc-c++ make autoconf cmake libtool libtool-libs glib2 glib2-devel bzip2 bzip2-devel libevent libevent-devel

yum -y install jemalloc jemalloc-devel

NGINX="nginx-1.16.0"
LIBRESSL="libressl-2.9.1"
ZLIB="zlib-1.2.11"
PCRE="pcre-8.42"

function download {
    printf "Downloading source files...\n"

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

    printf "Downloading complete.\n"
}

function extract {
    printf "Extracting source files...\n"
    rm -rf $NGINX
    tar zxf $NGINX.tar.gz
    rm -rf $LIBRESSL
    tar zxf $LIBRESSL.tar.gz
    rm -rf $ZLIB
    tar zxf $ZLIB.tar.gz
    rm -rf $PCRE
    tar zxf $PCRE.tar.gz
    printf "Extract complete.\n"
}

function buildNginx {
    printf "Build and install nginx...\n"
    cd $NGINX
    ./configure \
    --build=OC-Web \
    --prefix=/usr/share/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --pid-path=/run/nginx.pid \
    --lock-path=/run/lock/subsys/nginx \
    --user=www \
    --group=www \
    --with-threads \
    --with-file-aio \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_slice_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_auth_request_module \
    --with-stream \
    --with-stream_ssl_module \
    --without-select_module \
    --without-poll_module \
    --without-http_geo_module \
    --without-mail_pop3_module \
    --without-mail_imap_module \
     --without-mail_smtp_module \
    --without-stream_geo_module \
    --without-stream_map_module \
    --with-pcre=../$PCRE \
    --with-pcre-jit \
    --with-zlib=../$ZLIB \
    --with-openssl=../$LIBRESSL \
    --with-ld-opt="-lrt -ljemalloc -Wl,-z,relro -Wl,-E" \
    --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic -DTCP_FASTOPEN=3'

    #touch $LIBRESSL_DIR/.openssl/include/openssl/ssl.h
    make -j $(nproc) && make install

    mkdir -p /var/cache/nginx
    groupadd www
    useradd -d /var/www/ -m -r -s /sbin/nologin -g www www
    chown -R www:www /var/cache/nginx
    cp -r html/ /var/www/html/
    chown -R www:www /var/www

    cd ../../

    cp files/nginx.service /lib/systemd/system/nginx.service

    mkdir -p /etc/nginx/conf.d
    rm -f /etc/nginx/conf.d/default.conf
    cp -f files/nginx.conf /etc/nginx/nginx.conf
    cp -f files/conf.d/0-default.conf /etc/nginx/conf.d/0-default.conf



    systemctl enable nginx.service
    systemctl start nginx

    printf "Nginx has been installed and started. \nVisit http://$(hostname -i) to test.\n"

}

if [ ! -d "./source" ]; then
    mkdir ./source
fi

cd ./source

download

extract

#buildLibreSSL

buildNginx
