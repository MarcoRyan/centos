#!/bin/bash
clear
echo ""

#read -s -n1 -p "Press any key to continue..." 

echo "  1.Install v2ray                               2.Uninstall v2ray"
echo "  3.Check config                                4.Modify config"

read -p "Please input the number you choose:" main_no
if [ "$main_no" = "1" ]; then

yum install -y curl
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)

wget https://raw.githubusercontent.com/hityne/centos/main/config.json  -O -> /usr/local/etc/v2ray/config.json


userid=$(cat /proc/sys/kernel/random/uuid)
sed -i "8s/7966c347-b5f5-46a0-b720-ef2d76e1836a/$userid/" /usr/local/etc/v2ray/config.json

read -p "请设置端口号（默认24380）：" port
[ "$alterid" ！= "" ] && echo sed -i "3s/24380/$port/" /usr/local/etc/v2ray/config.json

read -p "请输入alterid（默认64）:" alterid
[ "$alterid" ！= "" ] && sed -i "10s/64/$alterid" /usr/local/etc/v2ray/config.json


service v2ray start
service v2ray status


elif [ "$main_no" = "2" ]; then
bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) --remove

elif [ "$main_no" = "3" ]; then
cat /usr/local/etc/v2ray/config.json

else
exit 0

fi
