#!/bin/bash

echo '== start mysql.sh ===================='


# rootのパスワード設定
mysql -e "UPDATE mysql.user SET Password = PASSWORD('chimera') WHERE User = 'root'"
# 匿名ユーザー削除
mysql -e "DELETE FROM mysql.user WHERE User=''"
# リモートからのrootログインを不可に設定
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
# テストデータベースの削除
mysql -e "DROP DATABASE IF EXISTS test"
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"

# 作業用ユーザー追加
mysql -e "CREATE USER '$1'@'%' IDENTIFIED BY '$2'"
mysql -e "GRANT ALL ON *.* TO '$1'@'%' WITH GRANT OPTION"

# リードレプリカ用ユーザー追加
mysql -e "CREATE USER 'ro_$1'@'%' IDENTIFIED BY '$2'"
mysql -e "GRANT SELECT ON *.* TO 'ro_$1'@'%' WITH GRANT OPTION"

# 設定を反映
mysql -e "FLUSH PRIVILEGES"


echo '== end mysql.sh ===================='
