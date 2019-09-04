#!/bin/sh

export LANG=C
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

NGINX_VER="1.14.0"

yum -y groupinstall 'Development Tools'
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install wget yum-utils
yum -y install pcre-devel lua-devel openssl-devel gd-devel geoip-devel cifs-utils

if [ -d /tmp/build ]; then
  rm -rf /tmp/build
fi

mkdir -p /tmp/build/
cd /tmp/build/
wget http://nginx.org/download/nginx-${NGINX_VER}.tar.gz
tar zxvf nginx-${NGINX_VER}.tar.gz
cd nginx-${NGINX_VER}

# git clone modules
git clone https://github.com/openresty/lua-nginx-module /usr/local/src/lua-nginx-module

# configure option
./configure \
--sbin-path=/usr/bin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--with-pcre \
--pid-path=/var/run/nginx.pid \
--with-http_ssl_module 
#--prefix=/etc/nginx  \
#--sbin-path=/usr/sbin/nginx  \
#--conf-path=/etc/nginx/nginx.conf  \
#--error-log-path=/var/log/nginx/error.log  \
#--http-log-path=/var/log/nginx/access.log  \
#--pid-path=/var/run/nginx.pid  \
#--lock-path=/var/run/nginx.lock  \
#--http-client-body-temp-path=/var/cache/nginx/client_temp  \
#--http-proxy-temp-path=/var/cache/nginx/proxy_temp  \
#--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp  \
#--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp  \
#--http-scgi-temp-path=/var/cache/nginx/scgi_temp  \
#--user=nginx  \
#--group=nginx  \
#--with-http_ssl_module  \
#--with-http_realip_module  \
#--with-http_addition_module  \
#--with-http_sub_module  \
#--with-http_dav_module  \
#--with-http_flv_module  \
#--with-http_mp4_module  \
#--with-http_gunzip_module  \
#--with-http_gzip_static_module  \
#--with-http_random_index_module  \
#--with-http_secure_link_module  \
#--with-http_stub_status_module  \
#--with-file-aio \
#--with-ipv6 \
#--with-pcre \
#--with-http_geoip_module \
#--with-http_image_filter_module \
#--with-http_stub_status_module \
#--add-module=/usr/local/src/lua-nginx-module/ \
#--with-cc-opt='-O2 -g -pipe -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic'

make

/tmp/build/nginx-${NGINX_VER}/objs/nginx -V

make install


#mkdir -p /sites/demo
#cp -R /vagrant/sites/demo/* /sites/demo/
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf-orig
#cp /sites/demo/nginx.conf /etc/nginx/nginx.conf
mkdir -p /sites/demo
ln -s /vagrant/sites/demo/ /sites/demo/
ln -s /vagrant/sites/demo/nginx.conf /etc/nginx/nginx.conf

cp /vagrant/nginx.service /lib/systemd/system/nginx.service

systemctl enable nginx
systemctl start nginx
systemctl status nginx

#systemctl reload nginx

echo "Done!!"