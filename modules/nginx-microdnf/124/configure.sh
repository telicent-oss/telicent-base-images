#!/bin/bash
set -e

RED="\033[31m"
END="\033[0m"

log() {
    echo "[INFO] $1"
}

error_exit() {
    echo -e "${RED} [ERROR] $1 ${END}" >&2
    exit 1
}

INSTALL_PREFIX="/usr/local/nginx"

log "Setting up log directory and permissions..."

mkdir -p /var/log/nginx
chown -R user:user /var/log/nginx
chmod -R g+w /var/log/nginx
ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log

log "Log directory and permissions configured successfully."

log "Implementing rootless changes for NGINX configuration..."
sed -i 's,listen       80;,listen       8080;,' /etc/nginx/nginx.conf
sed -i 's,user nginx,user user,' /etc/nginx/nginx.conf
sed -i 's,/var/run/nginx.pid,/tmp/nginx.pid,' /etc/nginx/nginx.conf
sed -i 's,root         /usr/share/nginx/html,root         /usr/local/nginx/html/,' /etc/nginx/nginx.conf
sed -i "/^http {/a \    proxy_temp_path /tmp/proxy_temp;\n    client_body_temp_path /tmp/client_temp;\n    fastcgi_temp_path /tmp/fastcgi_temp;\n    uwsgi_temp_path /tmp/uwsgi_temp;\n    scgi_temp_path /tmp/scgi_temp;\n" /etc/nginx/nginx.conf

log "Adjusting permissions for rootless operation..."
#chown -R $UID:0 /usr/local/nginx/cache
#chmod -R g+w /usr/local/nginx/cache
#chown -R $UID:0 /usr/local/nginx/conf
#chmod -R g+w /usr/local/nginx/conf
mkdir -p $INSTALL_PREFIX
chown -R $UID:0 $INSTALL_PREFIX
chmod -R g+w $INSTALL_PREFIX


log "Adding root to nginx group..."
usermod -a -G $UID root

log "Cleaning up build environment..."
cd /

ln -s $INSTALL_PREFIX/sbin/nginx /usr/sbin/nginx
log "NGINX $NGINX_VERSION installation complete and ready for rootless operation!"
