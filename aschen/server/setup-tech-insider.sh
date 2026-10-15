#!/bin/sh
set -eu
cd "$(dirname "$0")"

# 1. HTTP-only vhost so certbot can answer the ACME challenge
cp tech-insider.eu.http /etc/nginx/sites-available/tech-insider.eu
ln -sf /etc/nginx/sites-available/tech-insider.eu /etc/nginx/sites-enabled/tech-insider.eu
nginx -t && systemctl reload nginx

# 2. Certificate
certbot certonly --webroot -w /var/www/html -d tech-insider.eu -d www.tech-insider.eu --non-interactive --agree-tos --keep-until-expiring

# 3. Final vhost (HTTPS + catch-all)
cp tech-insider.eu /etc/nginx/sites-available/tech-insider.eu
nginx -t && systemctl reload nginx

echo "OK -> https://tech-insider.eu/articles/foobar-foo-barfoo.html"
