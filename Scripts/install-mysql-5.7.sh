#!/bin/bash
set -x
set -e

export DEBIAN_FRONTEND=noninteractive

curl -LO https://dev.mysql.com/get/mysql-apt-config_0.5.3-1_all.deb
echo mysql-apt-config mysql-apt-config/select-product          select Apply              | sudo debconf-set-selections
echo mysql-apt-config mysql-apt-config/select-server           select mysql-5.7          | sudo debconf-set-selections
echo mysql-apt-config mysql-apt-config/select-connector-python select none               | sudo debconf-set-selections
echo mysql-apt-config mysql-apt-config/select-workbench        select none               | sudo debconf-set-selections
echo mysql-apt-config mysql-apt-config/select-utilities        select none               | sudo debconf-set-selections
echo mysql-apt-config mysql-apt-config/select-connector-odbc   select connector-odbc-x.x | sudo debconf-set-selections
sudo -E dpkg -i mysql-apt-config_0.5.3-1_all.deb
sudo apt-get update
echo mysql-community-server mysql-community-server/re-root-pass password ${mysql_root_password} | sudo debconf-set-selections
echo mysql-community-server mysql-community-server/root-pass    password ${mysql_root_password} | sudo debconf-set-selections
sudo -E apt-get -y install mysql-community-server

echo "Checking installed version....."
mysql -D mysql -e "SELECT version()"
echo "Done!!"
