#!/bin/sh

# MIT License
# Copyright (c) 2020 Jack Rayner <me@jrayner.net>

# Kinda naughty, create a 2GB swapfile on the disk.
# (Useful for small droplets with low RAM)
fallocate -l 2G /swapfile
chmod 0600 /swapfile
mkswap /swapfile
swapon /swapfile
# Add required repos
apt-get update
apt-get install curl
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository universe
add-apt-repository ppa:certbot/certbot
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get install --assume-yes \
    apt-transport-https \
    ca-certificates \
    gnupg-agent \
    nginx \
    certbot \
    python-certbot-nginx \
    software-properties-common
apt-get install --assume-yes docker-ce docker-ce-cli containerd.io
# Enable nginx servce and run certbot
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

mkdir /etc/tiddlywiki/
cat <<EOF > /etc/systemd/system/wiki.service
# MIT License
# Copyright (c) 2020 Jack Rayner <me@jrayner.net>
[Unit]
Description=TiddlyWiki Container
After=docker.service
Requires=docker.service

[Service]
Restart=always
RestartSec=5
TimeoutStartSec=60
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=%n
Environment="TW_PORT=8080"
Environment="TW_DOCKERVOLUME=%n"
Environment="TW_DOCKERUID=0"
Environment="TW_DOCKERGID=0"
EnvironmentFile=/etc/tiddlywiki/%n.conf
ExecStartPre=-/usr/bin/docker stop %n
ExecStartPre=-/usr/bin/docker rm %n
ExecStartPre=/usr/bin/docker pull nicolaw/tiddlywiki
ExecStart=/usr/bin/docker run -p \$${TW_PORT}:\$${TW_PORT} -e TW_PORT=\$${TW_PORT} --env-file /etc/tiddlywiki/%n.conf --user \$${TW_DOCKERUID}:\$${TW_DOCKERGID} -v \$${TW_DOCKERVOLUME}:/var/lib/tiddlywiki --name %n nicolaw/tiddlywiki
ExecStop=-/usr/bin/docker stop %n
EOF
cat <<EOF > /etc/tiddlywiki/wiki.service.conf
# MIT License
# Copyright (c) 2020 Jack Rayner <me@jrayner.net>
#
# Refer to the canonical online documentation for help.
# - https://tiddlywiki.com/static/Using%2520TiddlyWiki%2520on%2520Node.js.html
# - https://tiddlywiki.com/static/ServerCommand.html
#
# Uncomment and change the key=value configuration pairs below.
#
TW_WIKINAME=wiki
TW_USERNAME=jack
TW_PASSWORD=password
TW_PORT=8080
#TW_ROOTTIDDLER=$:/core/save/all
#TW_RENDERTYPE=text/plain
#TW_SERVETYPE=text/html
#TW_HOST=0.0.0.0
#TW_PATHPREFIX=
#NODE_MEM=400
#NODE_OPTIONS=
TW_DOCKERVOLUME=/root/tiddlywiki
#TW_DOCKERUID=0
#TW_DOCKERGID=0
EOF
systemctl daemon-reload
systemctl start wiki.service
systemctl restart nginx.service