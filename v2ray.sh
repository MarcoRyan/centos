#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    clear
    echo "Error: This script must be run as root!" 1>&2
    exit 1
fi

function check_config(){
	ip=$(curl -s https://ipinfo.io/ip)
	echo "服务器地址：$ip"
	port=$(awk 'NR==3 {print $2}' /usr/local/etc/v2ray/config.json)
	port=${port:0:-1}
	echo "端口：$port"
	userid=$(awk 'NR==8 {print$2}' /usr/local/etc/v2ray/config.json)
	userid=${userid:1:-2}
	echo "用户id: $userid"
	alterid=$(awk 'NR==10 {print$2}' /usr/local/etc/v2ray/config.json)
	echo "额外id: $alterid"
	echo "传输协议：tcp"
	echo "伪装类型：none"
	echo "伪装域名："
	echo "伪装路径："
	echo "底层传输协议："


	cat >/usr/local/etc/v2ray/vmess_qr.json << EOF
				{
					"v": "2",
					"ps": "oracle",
					"add": "$ip",
					"port": "$port",
					"id": "$userid",
					"aid": "$alterid",
					"net": "tcp",
					"type": "none",
					"host": "",
					"path": "",
					"tls": ""
				} 
	EOF

	vmess="vmess://$(cat /usr/local/etc/v2ray/vmess_qr.json | base64 -w 0)"
	echo $vmess

}


clear
echo ""

#read -s -n1 -p "Press any key to continue..." 

echo "  1.Install v2ray                               2.Uninstall v2ray"
echo "  3.Check config                                4.Modify config"

echo ""
read -p "Please input the number you choose:" main_no
if [ "$main_no" = "1" ]; then

	yum install -y curl
	bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)

	wget https://raw.githubusercontent.com/hityne/centos/main/config.json  -O -> /usr/local/etc/v2ray/config.json


	userid=$(cat /proc/sys/kernel/random/uuid)
	sed -i "8s/7966c347-b5f5-46a0-b720-ef2d76e1836a/$userid/" /usr/local/etc/v2ray/config.json

	read -p "请设置端口号（默认24380）：" port
	[ "$port" != "" ] && sed -i "3s/24380/$port/" /usr/local/etc/v2ray/config.json

	read -p "请输入alterid（默认64）:" alterid
	[ "$alterid" != "" ] && sed -i "10s/64/$alterid/" /usr/local/etc/v2ray/config.json


	service v2ray start
	service v2ray status


elif [ "$main_no" = "2" ]; then
	bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) --remove

elif [ "$main_no" = "3" ]; then
	check_config

elif [ "$main_no" = "4" ]; then
	echo ""
	echo "  1.Module port                               2.Modify userid"
	echo ""
	read -p "Please input the number you choose:" sub_no

	if [ "$sub_no" = "1" ]; then

		old_port=$(awk 'NR==3 {print $2}' /usr/local/etc/v2ray/config.json)
		old_port=${port:0:-1}
		echo "原端口：$old_port"

		read -p "请设置端口号（默认24380）：" port
		[ "$port" != "" ] && sed -i "3s/24380/$port/" /usr/local/etc/v2ray/config.json

		new_port=$(awk 'NR==3 {print $2}' /usr/local/etc/v2ray/config.json)
		new_port=${port:0:-1}
		echo "原端口：$port"

	elif [ "$sub_no" = "2" ]; then
		old_userid=$(awk 'NR==8 {print$2}' /usr/local/etc/v2ray/config.json)
		old_userid=${userid:1:-2}
		echo "用户id: $old_userid"

		read -s -n1 -p "Press Enter to continue or press Ctrl+C to quit"
		userid=$(cat /proc/sys/kernel/random/uuid)
		sed -i "8s/7966c347-b5f5-46a0-b720-ef2d76e1836a/$userid/" /usr/local/etc/v2ray/config.json
		new_userid=$(awk 'NR==8 {print$2}' /usr/local/etc/v2ray/config.json)
		new_userid=${userid:1:-2}
		echo "用户id: $new_userid"
	else
	exit 0
	fi

else
exit 0

fi