#!/bin/bash


echo "Sqlite3 will be updated to a new version."
echo "Current Version："
sqlite3 -version

pause

yum install -y gcc
wget https://www.sqlite.org/2021/sqlite-autoconf-3350500.tar.gz
tar zxvf sqlite-autoconf-3350500.tar.gz
cd sqlite-autoconf-3350500/
./configure --prefix=/usr/local
make && make install
echo "sqlite3 update is completed！"
echo "New Version："
sqlite3 -version
