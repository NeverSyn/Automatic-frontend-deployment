#!/bin/bash
#Install EPEL
curr_dir=`pwd`;

cd /tmp
mkdir autoscript && cd autoscript
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && sudo rpm -Uvh epel-release-6*.rpm

#Install nginx
wget http://nginx.org/download/nginx-1.6.2.tar.gz
tar -xvf nginx-1.6.2.tar.gz
cd nginx*
yum install -y openssl openssl-devel zlib zlib-devel pcre pcre-devel gcc make
./configure --with-http_ssl_module --with-http_gzip_static_module --with-pcre --with-http_stub_status_module --prefix=/etc/nginx
make
make install
cp $curr_dir/../common/nginx_init_script /etc/init.d/nginx
chmod 755 /etc/init.d/nginx
chkconfig --add nginx
chkconfig --levels 345 nginx on
chkconfig | grep nginx
cp $curr_dir/../common/nginx.conf /etc/nginx/conf/nginx.conf
chown root:root /etc/nginx/conf/nginx.conf && chown 644 /etc/nginx/conf/nginx.conf
mkdir /etc/nginx/conf/sites-available
mkdir /etc/nginx/conf/sites-enabled
/etc/init.d/nginx start

#Install PHP-fpm
yum -y install php-fpm php-mysql php-mcrypt php-imap php-gd php-mbstring && chkconfig --levels 345 php-fpm on
cp $curr_dir/../common/php-fpm.conf /etc/php-fpm.d/www.conf
mkdir /var/lib/php/session
chown nobody:nobody /var/lib/php/session
chmod 777 /var/lib/php/session
/etc/init.d/php-fpm start

#Install PerconaDB 5.6 Server, client, and libraries
yum -y install http://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm
yum -y install Percona-Server-client-56.x86_64 Percona-Server-server-56.x86_64 Percona-Server-shared-56.x86_64 Percona-Server-devel-56.x86_64
/etc/init.d/mysql start
mysql -e "CREATE FUNCTION fnv1a_64 RETURNS INTEGER SONAME 'libfnv1a_udf.so'"
mysql -e "CREATE FUNCTION fnv_64 RETURNS INTEGER SONAME 'libfnv_udf.so'"
mysql -e "CREATE FUNCTION murmur_hash RETURNS INTEGER SONAME 'libmurmur_udf.so'"

#Install python 2.7.8
cd /tmp/autoscript
wget https://www.python.org/ftp/python/2.7.8/Python-2.7.8.tgz
tar -xvf Python-2.7.8.tgz
cd Python-2.7.8
yum install -y sqlite sqlite-devel ncurses ncurses-devel bzip2 bzip2-devel readline readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel python-virtualenv
./configure && make && make altinstall
