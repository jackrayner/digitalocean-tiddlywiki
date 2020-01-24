#!/bin/sh

fallocate -l 2G /swapfile
chmod 0600 /swapfile
mkswap /swapfile
swapon /swapfile
add-apt-repository universe
add-apt-repository ppa:certbot/certbot
apt-get update
apt-get install --assume-yes certbot python-certbot-nginx nodejs npm software-properties-common nginx
systemctl enable nginx
certbot certonly -n --agree-tos -m ${certbot_email} --nginx --domains "${hostname}.${domain}"
cat <<EOF > /etc/nginx/sites-enabled/default
server {
    listen 80;

    server_name _;
    return 301 https://${hostname}.${domain}\$request_uri;
}

server {
    server_name ${hostname}.${domain};

    access_log            /var/log/nginx/tiddlywiki.access.log;

    listen 443 ssl;
    ssl_certificate /etc/letsencrypt/live/${hostname}.${domain}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${hostname}.${domain}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    add_header Strict-Transport-Security "max-age=31536000" always;

    ssl_trusted_certificate /etc/letsencrypt/live/${hostname}.${domain}/chain.pem;
    ssl_stapling on; # managed by Certbot
    ssl_stapling_verify on; # managed by Certbot

    location / {

      proxy_set_header        Host \$host;
      proxy_set_header        X-Real-IP \$remote_addr;
      proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
      proxy_set_header        X-Forwarded-Proto \$scheme;

      proxy_pass          http://localhost:8080;
      proxy_read_timeout  90;

      proxy_redirect      http://localhost:8080 http://${hostname}.${domain};
    }
}
EOF
systemctl restart nginx
npm install -g tiddlywiki
tiddlywiki newwiki --init server
tiddlywiki newwiki --listen &
