#!/bin/bash

source ./common.sh

yum -y remove mariadb-libs

yum -y install perl
yum -y install libaio
yum -y install net-tools

rpm -ivh mysql-community-common-*.rpm
rpm -ivh mysql-community-libs-*.rpm
rpm -ivh mysql-community-client-*.rpm
rpm -ivh mysql-community-server-*.rpm

systemctl daemon-reload
systemctl start mysqld
systemctl enable mysqld

MYSQL_OLDPASS=$(awk '/temporary password/{print $NF}' /var/log/mysqld.log)
mysql -uroot -p"$MYSQL_OLDPASS" --connect-expired-password\
      -e"set global validate_password_policy=0;"
mysql -uroot -p"$MYSQL_OLDPASS" --connect-expired-password\
      -e"set global validate_password_length=4;"
mysql -uroot -p"$MYSQL_OLDPASS" --connect-expired-password\
      -e"alter user 'root'@'localhost' identified by '123456';"


run_mysql(){
    mysql -uroot -p123456 -e"$1"
}

run_mysql "create user 'root'@'%' identified by '123456'"
run_mysql "grant all privileges on *.* to 'root'@'%' with grant option"
run_mysql "flush privileges"
run_mysql "create database test"
 
