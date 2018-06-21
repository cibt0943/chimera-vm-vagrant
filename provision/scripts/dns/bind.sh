#!/bin/bash

echo '== start bind.sh ===================='


# bindのインストール
yum -y install bind bind-chroot bind-utils
echo '==> bind version:' | named -v

# dnsの設定ファイルをコピー
cp -f /vagrant/provision/tpl/bind_named.conf /etc/named.conf
cp -f /vagrant/provision/tpl/bind_zone_lan.conf /var/named/chimera.lan.db
cp -f /vagrant/provision/tpl/bind_zone_com.conf /var/named/chimera.com.db

# dnsの自動起動
systemctl start named-chroot
systemctl enable named-chroot.service


echo '== end bind.sh ===================='
