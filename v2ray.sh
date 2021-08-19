#!/bin/bash

echo ""

read -s -n1 -p "Press any key to continue..." 


yum install -y curl
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)

wget https://raw.githubusercontent.com/hityne/centos/main/config.json  -O -> /usr/local/etc/v2ray/config.json


userid=$(cat /proc/sys/kernel/random/uuid)
sed -i "s/7966c347-b5f5-46a0-b720-ef2d76e1836a/$userid/" /usr/local/etc/v2ray/config.json


read -p "请输入alterid（默认64）:" alterid
[ "$alterid" == "" ] && echo alterid=64
echo "alter id: $alterid"
sed -i "s/\"alterId\": 64/\"alterId:\" $alterid/" /usr/local/etc/v2ray/config.json


systemctl start v2ray
systemctl status v2ray
