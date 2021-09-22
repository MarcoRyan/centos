#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    clear
    echo "Error: This script must be run as root!" 1>&2
    exit 1
fi

function check_config(){

	cat /usr/local/etc/v2ray/config.json

	rows=$(awk 'END {print NR}' /usr/local/etc/v2ray/config.json )
	
	if [ $rows == 32 ]; then
		echo ""
		echo "vmess+tcp"
		echo ""
		ip=$(curl -s https://ipinfo.io/ip)
		port=$(cat /usr/local/etc/v2ray/config.json | awk 'NR==3 {print substr($2,0,length($2)-1)}')
		userid=$(cat /usr/local/etc/v2ray/config.json | awk 'NR==8 {print substr($2,0,length($2)-1)}')
		alterid=$(cat /usr/local/etc/v2ray/config.json | awk 'NR==10 {print $2}')

		cat >/usr/local/etc/v2ray/vmess_qr.json << EOF
				{
					"v": "2",
					"ps": "",
					"add": "$ip",
					"port": "$port",
					"id": $userid,
					"aid": "$alterid",
					"net": "tcp",
					"type": "none",
					"host": "",
					"path": "",
					"tls": ""
				} 
EOF
	elif [ $rows == 47 ]; then
		echo ""
		echo "vmess+ws+tls"
		echo ""
		port=$(cat /usr/local/etc/v2ray/config.json | awk 'NR==4 {print substr($2,0,length($2)-1)}')
		userid=$(cat /usr/local/etc/v2ray/config.json | awk 'NR==9 {print substr($2,0,length($2)-1)}')
		alterid=$(cat /usr/local/etc/v2ray/config.json | awk 'NR==11 {print $2}')
		urpath=$(cat /usr/local/etc/v2ray/config.json | awk 'NR==18 {print $2}')
		urdomain=$(cat /usr/local/etc/v2ray/domain.txt)

		cat >/usr/local/etc/v2ray/vmess_qr.json << EOF
				{
					"v": "2",
					"ps": "",
					"add": "$urdomain",
					"port": "443",
					"id": $userid,
					"aid": "$alterid",
					"net": "ws",
					"type": "none",
					"host": "",
					"path": $urpath,
					"tls": "tls"
				} 
EOF
	else
		echo ""
		echo "Please check your config."
		exit 0
	fi

	vmess="vmess://$(cat /usr/local/etc/v2ray/vmess_qr.json | base64 -w 0)"
	echo $vmess
	echo ""

}


clear
echo ""

#read -s -n1 -p "Press any key to continue..." 

echo "  1.Install v2ray                               2.Uninstall v2ray"
echo "  3.Check config                                4.Modify config"
echo "  5.Install docker_v2ray"


echo ""
read -p "Please input the number you choose:" main_no
if [ "$main_no" = "1" ]; then
	clear
	echo ""
	echo "  1.Install v2ray tcp"
	echo "  2.Install v2ray ws+tls+web"
	echo ""
	read -p "Please input the number you choose:" v2ray_no

	if [ "$v2ray_no" = "1" ]; then

		yum install -y curl
		bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
		wget https://github.com/hityne/centos/raw/ur/config.json  -O -> /usr/local/etc/v2ray/config.json

		userid=$(cat /proc/sys/kernel/random/uuid)
		sed -i "8s/7966c347-b5f5-46a0-b720-ef2d76e1836a/$userid/" /usr/local/etc/v2ray/config.json

		read -p "请设置端口号（默认24380）: " port
		[ "$port" != "" ] && sed -i "3s/24380/$port/" /usr/local/etc/v2ray/config.json

		read -p "请输入alterid（默认64）: " alterid
		[ "$alterid" != "" ] && sed -i "10s/64/$alterid/" /usr/local/etc/v2ray/config.json


	elif [ "$v2ray_no" = "2" ]; then

		yum install -y curl
		bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
		wget https://github.com/hityne/centos/raw/ur/config2.json  -O -> /usr/local/etc/v2ray/config.json

		read -p "请输入你的域名: " urdomain
		[ "$urdomain" == "" ] && read -p "请输入你的域名：" urdomain
		echo $urdomain > /usr/local/etc/v2ray/domain.txt

		userid=$(cat /proc/sys/kernel/random/uuid)
		sed -i "9s/7966c347-b5f5-46a0-b720-ef2d76e1836a/$userid/" /usr/local/etc/v2ray/config.json

		read -p "请设置端口号（默认35367）: " port
		[ "$port" != "" ] && sed -i "4s/35367/$port/" /usr/local/etc/v2ray/config.json

		read -p "请输入alterid（默认64）: " alterid
		[ "$alterid" != "" ] && sed -i "11s/64/$alterid/" /usr/local/etc/v2ray/config.json

		read -p "请输入path（默认"down"）:" urpath
		[ "$urpath" != "" ] && sed -i "18s/down/$urpath/" /usr/local/etc/v2ray/config.json


	echo ""
	echo "*******************"
	echo "请开通端口 $port"
	echo "请为$urdomain申请SSL认证"
	wget https://raw.githubusercontent.com/hityne/centos/ur/site.config  -O -> /usr/local/etc/v2ray/site.config
	echo "网站配置文件添加以下内容(/usr/local/etc/v2ray/site.config)："
	cat /usr/local/etc/v2ray/site.config
	echo "*******************"
	echo ""

	else
	exit 0
	fi

    systemctl enable v2ray
	service v2ray start
	service v2ray status




elif [ "$main_no" = "2" ]; then
	bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) --remove

elif [ "$main_no" = "3" ]; then
	check_config

elif [ "$main_no" = "4" ]; then
	rows=$(awk 'END {print NR}' /usr/local/etc/v2ray/config.json )
	if [ $rows == 32 ]; then
		echo ""
		echo "vmess+tcp"
		echo "If you are not an advanced user, please do not modify itmes other than port and userid."
		echo 'After you save the configure, please restart v2ray service.'
		echo ""
		vim /usr/local/etc/v2ray/config.json

	elif [ $rows == 47 ]; then
		echo ""
		echo "vmess+ws+tls"
		echo "If you are not an advanced user, please do not modify itmes other than port and userid."
		echo 'After you save the configure, please restart v2ray service.'
		echo ""
		vim /usr/local/etc/v2ray/config.json
	else
		exit 0
	fi

elif [ "$main_no" = "5" ]; then
	clear
	if systemctl is-active docker &>/dev/null ;then
		echo "docker已经启动"
	else
		echo "docker未启动"
		echo "请先启动docker服务"
		echo ""
		exit 0
	fi
	echo ""
	echo "  1.Install v2ray tcp"
	echo "  2.Install v2ray ws+tls+web"
	echo ""
	read -p "Please input the number you choose:" v2ray_no

	if [ "$v2ray_no" = "1" ]; then

		mkdir -p /usr/local/etc/v2ray
		wget https://github.com/hityne/centos/raw/ur/config.json  -O -> /usr/local/etc/v2ray/config.json

		userid=$(cat /proc/sys/kernel/random/uuid)
		sed -i "8s/7966c347-b5f5-46a0-b720-ef2d76e1836a/$userid/" /usr/local/etc/v2ray/config.json

		read -p "请设置端口号（默认24380）： " port
		[ "$port" != "" ] && sed -i "3s/24380/$port/" /usr/local/etc/v2ray/config.json
		[ "$port" = "" ] && port=35367

		read -p "请输入alterid（默认64）: " alterid
		[ "$alterid" != "" ] && sed -i "10s/64/$alterid/" /usr/local/etc/v2ray/config.json

		docker run -d --name v2ray_tcp --restart=always -v /usr/local/etc/v2ray:/etc/v2ray -p $port:$port v2fly/v2fly-core  v2ray -config=/etc/v2ray/config.json


	elif [ "$v2ray_no" = "2" ]; then

		mkdir -p /usr/local/etc/v2ray
		wget https://github.com/hityne/centos/raw/ur/config2.json  -O -> /usr/local/etc/v2ray/config.json
		
		sed -i "5s/127.0.0.1/0.0.0.0/" /usr/local/etc/v2ray/config.json

		read -p "请输入你的域名: " urdomain
		[ "$urdomain" == "" ] && read -p "请输入你的域名: " urdomain
		echo $urdomain > /usr/local/etc/v2ray/domain.txt

		userid=$(cat /proc/sys/kernel/random/uuid)
		sed -i "9s/7966c347-b5f5-46a0-b720-ef2d76e1836a/$userid/" /usr/local/etc/v2ray/config.json

		read -p "请设置端口号（默认35367）: " port
		[ "$port" != "" ] && sed -i "4s/35367/$port/" /usr/local/etc/v2ray/config.json
		[ "$port" = "" ] && port=35367

		read -p "请输入alterid（默认64）: " alterid
		[ "$alterid" != "" ] && sed -i "11s/64/$alterid/" /usr/local/etc/v2ray/config.json

		read -p "请输入path（默认"down"）: " urpath
		[ "$urpath" != "" ] && sed -i "18s/down/$urpath/" /usr/local/etc/v2ray/config.json

		docker run -d --name v2ray_ws_tls --restart=always -v /usr/local/etc/v2ray:/etc/v2ray -p 127.0.0.1:$port:$port v2fly/v2fly-core  v2ray -config=/etc/v2ray/config.json
		
		echo ""
		echo "*******************"
		echo "请开通端口 $port"
		echo "请为$urdomain申请SSL认证"
		wget https://github.com/hityne/centos/raw/ur/site.config  -O -> /usr/local/etc/v2ray/site.config
		echo "网站配置文件添加以下内容(/usr/local/etc/v2ray/site.config)："
		cat /usr/local/etc/v2ray/site.config
		echo "*******************"
		echo ""


	else
	exit 0
	fi
	
else
exit 0

fi
