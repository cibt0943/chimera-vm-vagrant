#!/bin/bash

echo '== start bind.sh ===================='


# bindのインストール
yum -y install bind bind-chroot bind-utils
echo '==> bind version:' | named -v

# dnsの設定ファイルをコピー
cp -f /vagrant/provision/dns/tpl/bind-named.conf /etc/named.conf
cp -f /vagrant/provision/dns/tpl/bind-zone-lan.conf /var/named/tamechimera.lan.db
cp -f /vagrant/provision/dns/tpl/bind-zone-com.conf /var/named/tamechimera.com.db

# dnsの自動起動
systemctl start named-chroot
systemctl enable named-chroot.service


echo '== end bind.sh ===================='
