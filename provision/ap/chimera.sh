#!/bin/bash

echo '== start chimera.sh ===================='


rails_env=$1
ap_server_global_domain=$2

sudo yum update
sudo yum -y install wget gcc-c++

# nginxのrpmインストール
sudo yum -y install http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
# nginxのインストール
sudo yum -y install nginx
echo '==> nginx version:' | nginx -v

# SSL証明書作成
sudo mkdir /etc/nginx/ssl
sudo sh -c 'openssl genrsa 2048 > /etc/nginx/ssl/server.key'
sudo sh -c 'openssl req -new -batch -key /etc/nginx/ssl/server.key > /etc/nginx/ssl/server.csr'
sudo sh -c 'openssl x509 -req -days 3650 -signkey /etc/nginx/ssl/server.key < /etc/nginx/ssl/server.csr > /etc/nginx/ssl/server.crt'

# nginxのdefault.confファイルを作成
sudo cp -f /vagrant/provision/ap/tpl/nginx-chimera.conf /etc/nginx/conf.d/default.conf
# 値を書き換え
sudo sed -i -e "s/(ap_server_global_domain)/$ap_server_global_domain/g" /etc/nginx/conf.d/default.conf

# マシン起動時にvar/runの下にpumaディレクトリを作成
sudo sh -c "echo 'D /var/run/puma/chimera 0777 root root' >> /etc/tmpfiles.d/puma.conf"
# 再起動しないと作成されないのでプロビジョニング時は手動で作成
if [ ! -e /var/run/puma/chimera ]; then
  sudo mkdir -p -m 0777 /var/run/puma/chimera
fi

# puma自動起動用ファイルをコピー
sudo cp -f /vagrant/provision/ap/tpl/puma-chimera.service /usr/lib/systemd/system/puma-chimera.service
sudo sed -i -e "s/(rails_env)/$rails_env/g" /usr/lib/systemd/system/puma-chimera.service

# puma自動起動設定
# sudo systemctl disable puma-chimera.service
# sudo systemctl enable puma-chimera.service

# nginx自動起動設定
sudo systemctl disable nginx.service
sudo systemctl enable nginx.service

echo '==> end nginx and puma'

# gemに必要なライブラリをインストール
# node for rails js runtime
curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo yum -y install nodejs

# for nokogiri
sudo yum -y install libxml2-devel libxslt-devel

# for mysql
sudo yum -y install mysql-devel

# for rails-erd
sudo yum -y install graphviz

# mysqlのrpmインストール
# sudo yum -y install http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm
# mysql5.6 client community版をインストール
# sudo yum -y --enablerepo=mysql56-community install mysql-community-client

# for shrine
# sudo yum -y install ImageMagick ImageMagick-devel

# for front package manage
curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
sudo yum -y install yarn

echo '==> end yum'

cd /var/www/rails_app/chimera

sudo gem update bundler

rm -rf vendor/bundle
mkdir -p vendor/bundle
bundle config build.nokogiri --use-system-libraries
bundle install

echo '==> end bundle'

rm -rf node_modules
yarn install

echo '==> end yarn'

# DB作成
bin/rails db:create RAILS_ENV=development
bin/rails db:migrate RAILS_ENV=development
bin/rails db:create RAILS_ENV=test
bin/rails db:migrate RAILS_ENV=test

echo '==> end db'

# nginx再起動
sudo systemctl restart nginx

sudo yum clean all


echo '== end chimera.sh ===================='
