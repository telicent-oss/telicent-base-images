#!/bin/bash
set -e

NGINX_SRC_URL="http://nginx.org/download/nginx-${NGINX_VERSION:-1.27.2}.tar.gz"

RED="\033[31m"
END="\033[0m"

log() {
    echo "[INFO] $1"
}

error_exit() {
    echo -e "${RED} [ERROR] $1 ${END}" >&2
    exit 1
}

BUILD_DIR="/tmp/nginx-build"
INSTALL_PREFIX="/usr/local/nginx"

log "Preparing build environment..."
mkdir -p $BUILD_DIR
cd $BUILD_DIR

log "Setting up log directory and permissions..."

mkdir -p /var/log/nginx
chown -R user:user /var/log/nginx
chmod -R g+w /var/log/nginx
ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log

log "Log directory and permissions configured successfully."

log "Downloading NGINX source..."
wget "${NGINX_SRC_URL}"
wget "${NGINX_SRC_URL}.asc"

log "Importing NGINX GPG key..."
gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "${NGINX_GPG_KEY}"

log "Verifying NGINX source tarball..."
gpg --verify "nginx-${NGINX_VERSION}.tar.gz.asc" "nginx-${NGINX_VERSION}.tar.gz"

log "Extracting NGINX source..."
tar -xzf "nginx-${NGINX_VERSION}.tar.gz"
cd "nginx-${NGINX_VERSION}"

log "Configuring NGINX..."
./configure \
  --prefix=$INSTALL_PREFIX \
  --user=nginx \
  --group=nginx \
  --with-http_ssl_module \
  --with-http_v2_module \
  --with-http_gzip_static_module \
  --with-stream \
  --with-pcre

log "Building NGINX..."
make -j$(nproc)

log "Installing NGINX..."
make install

log "Implementing rootless changes for NGINX configuration..."
sed -i 's,listen       80;,listen       8080;,' /usr/local/nginx/conf/nginx.conf
sed -i '/user  nginx;/d' /usr/local/nginx/conf/nginx.conf
sed -i 's,/var/run/nginx.pid,/tmp/nginx.pid,' /usr/local/nginx/conf/nginx.conf
sed -i "/^http {/a \    proxy_temp_path /tmp/proxy_temp;\n    client_body_temp_path /tmp/client_temp;\n    fastcgi_temp_path /tmp/fastcgi_temp;\n    uwsgi_temp_path /tmp/uwsgi_temp;\n    scgi_temp_path /tmp/scgi_temp;\n" /usr/local/nginx/conf/nginx.conf

log "Adjusting permissions for rootless operation..."
#chown -R $UID:0 /usr/local/nginx/cache
#chmod -R g+w /usr/local/nginx/cache
#chown -R $UID:0 /usr/local/nginx/conf
#chmod -R g+w /usr/local/nginx/conf
chown -R $UID:0 $INSTALL_PREFIX
chmod -R g+w $INSTALL_PREFIX


log "Adding root to nginx group..."
usermod -a -G $UID root

log "Cleaning up build environment..."
cd /
rm -rf $BUILD_DIR

ln -s $INSTALL_PREFIX/sbin/nginx /usr/sbin/nginx
log "NGINX $NGINX_VERSION installation complete and ready for rootless operation!"
