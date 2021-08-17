#!/bin/bash

yum install -y gcc
wget https://www.sqlite.org/2021/sqlite-autoconf-3350500.tar.gz
tar zxvf sqlite-autoconf-3350500.tar.gz
cd sqlite-autoconf-3350500/
./configure --prefix=/usr/local
make && make install
echo "sqlite3升级完成！"
echo "当前版本号："
sqlite3 -version
