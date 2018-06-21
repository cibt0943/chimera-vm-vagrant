#!/bin/bash

echo '== start resolv.sh ===================='


# スクリプトファイルのルートへ移動
cd /vagrant/provision

# resolv固定化
sed -i -e "/^\[main/a dns=none" /etc/NetworkManager/NetworkManager.conf
systemctl restart NetworkManager
sed -i -e "/^nameserver/c nameserver $1" /etc/resolv.conf


echo '== end resolv.sh ===================='
