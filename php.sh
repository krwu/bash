#!/usr/bin/env sh

yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm

yum -y install yum-utils

yum-config-manager --enable remi-php71

yum makecache fast && yum -y update

yum -y install php-cli php-fpm php-opcache php-mbstring php-mysqlnd php-xml php-pecl-apcu php-pecl-redis php-pecl-memcached

rm -rf /etc/php-fpm.d/*

unalias cp

cp -f files/php.ini /etc/php.ini
cp -f files/php-fpm.conf /etc/php-fpm.conf
cp -f files/php-fpm.d/* /etc/php-fpm.d/

php-fpm -t

systemctl enable php-fpm.service
systemctl start php-fpm.service
