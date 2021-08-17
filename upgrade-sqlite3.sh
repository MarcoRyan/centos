#!/bin/bash

clear

echo ""
echo "This script will upgrade sqlite3 to a new version (3.35 2021)."
echo "The current version:"
sqlite3 -version
echo ""

read -s -n1 -p "Press any key to continue..." 


yum install -y gcc
wget https://www.sqlite.org/2021/sqlite-autoconf-3350500.tar.gz
tar zxvf sqlite-autoconf-3350500.tar.gz
cd sqlite-autoconf-3350500/
./configure --prefix=/usr/local
make && make install

mv /usr/bin/sqlite3  /usr/bin/sqlite3_old
ln -s /usr/local/bin/sqlite3   /usr/bin/sqlite3
echo "/usr/local/lib" > /etc/ld.so.conf.d/sqlite3.conf
ldconfig

echo ""
echo "The sqlite3 upgrade is done!"
echo "Ihe new version:"
sqlite3 -version
