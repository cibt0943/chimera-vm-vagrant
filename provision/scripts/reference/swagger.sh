#!/bin/bash

echo '==> start swagger.sh'


ap_server_name=$1

# スクリプトファイルのルートへ移動
cd /vagrant/provision

# wgetインストールして、swagger-uiをクローンしてくる
wget --no-check-certificate https://github.com/swagger-api/swagger-ui/archive/v3.2.0.tar.gz
tar xpvf v3.2.0.tar.gz
rm v3.2.0.tar.gz
# フォルダー中身を所定の位置にコピー、dist/を上書きしないように差分のみコピー
mkdir -p /var/www/swagger-ui
rsync -r swagger-ui-3.2.0/* /var/www/swagger-ui
rm -r swagger-ui-3.2.0

# 追加のjsをコピー
cp -f tpl/custom.js /var/www/swagger-ui/dist/custom.js

# 追加したjsをindex.htmlで読み込むためにファイルに追記
sed -i "/<\/body>/s/^/<script src=\"\.\/custom\.js\"> <\/script>/g" /var/www/swagger-ui/dist/index.html

# defaultのurlを変更
sed -i "s/http:\/\/petstore.swagger.io\/v2\/swagger.json/\/docs\/v1\/swagger.yaml/g" /var/www/swagger-ui/dist/index.html

# nginxの設定追加
cat /etc/nginx/conf.d/default.conf tpl/nginx_swagger.conf >> /etc/nginx/conf.d/default.conf
sed -i -e "s/(ap_server_name)/$ap_server_name/g" /etc/nginx/conf.d/default.conf


echo '==> end swagger.sh'
