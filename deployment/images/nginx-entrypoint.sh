#!/bin/sh
set -e

rm /etc/nginx/conf.d/default.conf || true

cat <<EOF > /etc/nginx/conf.d/portchain.conf
server {
  listen       80;
  listen       443 ssl;
  server_name  localhost;

  ssl_certificate  /etc/nginx/ssl/server.crt;
  ssl_certificate_key /etc/nginx/ssl/server.key;

  location / {
    proxy_pass http://${PORTCHAIN_HOST:-localhost}:${PORTCHAIN_PORT:-3000};
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_cache_bypass \$http_upgrade;
  }
}
EOF

exec nginx -g "daemon off"\;