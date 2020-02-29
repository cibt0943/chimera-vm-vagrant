#!/bin/bash
echo '== start mysql.sh ===================='

generated_password=$(grep 'temporary password' /var/log/mysqld.log | grep -Eo '[^ ]+$')
temporary_password='MyNewTempPass123!'

# 初期パスワードでログインはできるが、ALTER USER以外のクエリ発行時に以下エラーが発生するため一時的にパスワードを変更
# fix: ERROR 1820 (HY000): You must reset your password using ALTER USER statement before executing this statement.
mysql --silent --connect-expired-password --user root --password="${generated_password}" <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${temporary_password}';
SQL

# 正式なパスワードに変更
mysql --silent --user root --password="${temporary_password}" <<SQL
UNINSTALL PLUGIN validate_password;
-- rootのパスワード設定
ALTER USER 'root'@'localhost' IDENTIFIED BY 'chimera';
-- 作業用ユーザー追加
CREATE USER '$1'@'%' IDENTIFIED BY '$2';
GRANT ALL ON *.* TO '$1'@'%' WITH GRANT OPTION;
-- リードレプリカ用ユーザー追加
CREATE USER 'ro_$1'@'%' IDENTIFIED BY '$2';
GRANT SELECT ON *.* TO 'ro_$1'@'%' WITH GRANT OPTION;
SQL

cp -f /vagrant/provision/db/tpl/my.cnf /etc/my.cnf
systemctl restart mysqld

echo '== end mysql.sh ===================='
