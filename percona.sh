#!/usr/bin/env sh

yum -y install http://www.percona.com/downloads/percona-release/redhat/0.1-4/percona-release-0.1-4.noarch.rpm

yum -y install Percona-Server-server-57 Percona-Server-client-57

cp -f files/percona.cnf /etc/my.cnf

echo "LD_PRELOAD=/usr/lib64/libjemalloc.so" > /etc/sysconfig/mysql

mkdir -p /data/db

INITIAL=`mysqld --defaults-file=/etc/my.cnf --user=mysql --initialize-insecure`

systemctl enable mysqld
systemctl start mysqld

if [ ! -n "$1" ]; then
    mysqladmin -u root password "$1"
fi
