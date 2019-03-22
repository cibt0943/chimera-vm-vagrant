#!/bin/bash

echo '== start chimera.sh ===================='

rails_env=$1
ap_code=$2
ap_server_global_name=$3".com"
ap_dir_name=$4

# スクリプトファイルのルートへ移動
cd /vagrant/provision

sudo yum -y install wget gcc-c++

# nginxのrpmインストール
sudo yum -y install http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
# nginxのインストール
sudo yum -y install nginx
echo '==> nginx version:' | nginx -v

# nginxのdefault.confファイルを作成
sudo sh -c "echo -e 'server_tokens off;\n' > /etc/nginx/conf.d/default.conf"

# nginxのupstreamを追記
sudo sh -c "cat /etc/nginx/conf.d/default.conf tpl/nginx_ap_upstream.conf >> /etc/nginx/conf.d/default.conf"
# nginxのglobal側を追記
sudo sh -c "cat /etc/nginx/conf.d/default.conf tpl/nginx_ap_host_global.conf >> /etc/nginx/conf.d/default.conf"
# 値を書き換え
sudo sed -i -e "s/(ap_code)/$ap_code/g" /etc/nginx/conf.d/default.conf
sudo sed -i -e "s/(ap_server_global_name)/$ap_server_global_name/g" /etc/nginx/conf.d/default.conf
sudo sed -i -e "s/(ap_dir_name)/$ap_dir_name/g" /etc/nginx/conf.d/default.conf

# マシン起動時にvar/runの下にpumaディレクトリを作成
sudo sh -c "echo 'D /var/run/puma/$ap_code 0777 root root' >> /etc/tmpfiles.d/puma.conf"
# 再起動しないと作成されないのでプロビジョニング時は手動で作成
if [ ! -e /var/run/puma/$ap_code ]; then
  sudo mkdir -p -m 0777 /var/run/puma/$ap_code
fi

# puma自動起動用ファイルをコピー
sudo cp tpl/puma.service /usr/lib/systemd/system/puma-$ap_code.service
sudo sed -i -e "s/(ap_code)/$ap_code/g" /usr/lib/systemd/system/puma-$ap_code.service
sudo sed -i -e "s/(ap_dir_name)/$ap_dir_name/g" /usr/lib/systemd/system/puma-$ap_code.service
sudo sed -i -e "s/(rails_env)/$rails_env/g" /usr/lib/systemd/system/puma-$ap_code.service

# puma自動起動設定
sudo systemctl disable puma-$ap_code.service
sudo systemctl enable puma-$ap_code.service

# nginx自動起動設定
sudo systemctl disable nginx.service
sudo systemctl enable nginx.service

echo '==> end nginx and puma'

# gemに必要なライブラリをインストール
# for rails js runtime
curl -sL https://rpm.nodesource.com/setup_8.x | sudo bash -
sudo yum -y install nodejs

# for mysql
sudo yum -y install mysql-devel

# mysqlのrpmインストール
sudo yum -y install http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
# mysqlのrpmは明示的に利用
sudo sed -i -e 's/enabled *= *1/enabled=0/g' /etc/yum.repos.d/mysql-community.repo
# mysql5.6 client community版をインストール
sudo yum -y --enablerepo=mysql56-community install mysql-community-client

# for shrine
sudo yum -y install ImageMagick ImageMagick-devel

# for webpack
sudo wget https://dl.yarnpkg.com/rpm/yarn.repo -O /etc/yum.repos.d/yarn.repo
sudo yum -y install yarn

echo '==> end yum'

cd /var/www/rails_app/$ap_dir_name

## ホストOSがWindowsの場合 ##
# # vendor/bundleの下にgemを入れたいがホストPCがWindowsの場合、
# # ファイルシステムの違いによりsynced_folder内にgemを置く事が出来ない。
# # その為、/var/www/rails_bundleにgemを置き、vendor/bundleには参考ソースとしてコピーを置いておく

# # bundleにてgemを/var/www/rails_bundleディレクトリにインストール
# sudo rm -rf /var/www/rails_bundle/$ap_dir_name
# sudo mkdir -p /var/www/rails_bundle/$ap_dir_name
# sudo chmod 777 /var/www/rails_bundle/$ap_dir_name
# bundle install --path=/var/www/rails_bundle/$ap_dir_name/

# # bundleにて/var/www/rails_bundleディレクトリに入れたgemをrailsプロジェクトの中にコピー
# rm -rf vendor/bundle
# rm -rf vendor/bundle
# mkdir vendor/bundle
# cp -rf /var/www/rails_bundle/$ap_dir_name/. vendor/bundle

## ホストOSがWindows以外の場合 ##
rm -rf vendor/bundle
mkdir vendor/bundle
bundle install --path=vendor/bundle

echo '==> end bundle'

yarn install --no-bin-links

echo '==> end yarn'

# DB作成
bin/rails db:create RAILS_ENV=development
bin/rails db:migrate RAILS_ENV=development
bin/rails db:create RAILS_ENV=test
bin/rails db:migrate RAILS_ENV=test

echo '==> end db'

# nginx起動
sudo nginx -s stop
sudo nginx

sudo yum clean all


echo '== end chimera.sh ===================='
