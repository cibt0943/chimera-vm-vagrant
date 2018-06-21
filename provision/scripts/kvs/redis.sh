#!/bin/bash

echo '== start redis.sh ===================='


# remiのrpmインストール
# yum -y install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

# redisのインストール
yum -y --enablerepo=epel install redis
echo '==> redis version:' | redis-server --version

# redisへのアクセス可能IPを無制限に設定
cp /etc/redis.conf /etc/redis.conf.backup
sed -i -e 's/bind *127.0.0.1/bind 0.0.0.0/' /etc/redis.conf

# redis起動
systemctl start redis.service
systemctl enable redis.service

# firewallにてredisが使う6379ポートへのアクセスを許可(firewall自体を停止している)
#firewall-cmd --permanent --add-port=6379/tcp
#firewall-cmd --reload


echo '== end redis.sh ===================='