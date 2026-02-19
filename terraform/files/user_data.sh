#!/bin/bash
set -eux

yum update -y
yum install -y nginx git

# Node.js 20 をインストール
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
yum install -y nodejs

# nginxの設定ファイル書き込み
cat <<'NGINXCONF' > /etc/nginx/conf.d/default.conf
${nginx_conf}
NGINXCONF

# nginx 起動
systemctl enable nginx
systemctl start nginx

# GitHub から clone
cd /tmp
git clone https://github.com/yonahara-yu/webapp-learning.git
cd webapp-learning/frontend

# distをビルド
npm install
npm run build

# nginx 配信用ディレクトリにコピー
rm -rf /usr/share/nginx/html/*
cp -r dist/* /usr/share/nginx/html/

systemctl reload nginx