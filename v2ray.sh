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
					"id": "$userid",
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
		cat >/usr/local/etc/v2ray/vmess_qr.json << EOF
				{
					"v": "2",
					"ps": "",
					"add": $urdomain,
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
		wget https://raw.githubusercontent.com/hityne/centos/main/config.json  -O -> /usr/local/etc/v2ray/config.json

		userid=$(cat /proc/sys/kernel/random/uuid)
		sed -i "8s/7966c347-b5f5-46a0-b720-ef2d76e1836a/$userid/" /usr/local/etc/v2ray/config.json

		read -p "请设置端口号（默认24380）：" port
		[ "$port" != "" ] && sed -i "3s/24380/$port/" /usr/local/etc/v2ray/config.json

		read -p "请输入alterid（默认64）:" alterid
		[ "$alterid" != "" ] && sed -i "10s/64/$alterid/" /usr/local/etc/v2ray/config.json

# 		ip=$(curl -s https://ipinfo.io/ip)

# 		cat >/usr/local/etc/v2ray/vmess_qr.json << EOF
# 				{
# 					"v": "2",
# 					"ps": "",
# 					"add": "$ip",
# 					"port": "$port",
# 					"id": $userid,
# 					"aid": "$alterid",
# 					"net": "tcp",
# 					"type": "none",
# 					"host": "",
# 					"path": "",
# 					"tls": ""
# 				} 
# EOF

	elif [ "$v2ray_no" = "2" ]; then

		yum install -y curl
		bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
		wget https://github.com/hityne/centos/raw/ur/config2.json  -O -> /usr/local/etc/v2ray/config.json

		read -p "请输入你的域名：" urdomain
		[ "$urdomain" == "" ] && read -p "请输入你的域名：" urdomain

		userid=$(cat /proc/sys/kernel/random/uuid)
		sed -i "9s/7966c347-b5f5-46a0-b720-ef2d76e1836a/$userid/" /usr/local/etc/v2ray/config.json

		read -p "请设置端口号（默认35367）：" port
		[ "$port" != "" ] && sed -i "4s/35367/$port/" /usr/local/etc/v2ray/config.json

		read -p "请输入alterid（默认64）:" alterid
		[ "$alterid" != "" ] && sed -i "11s/64/$alterid/" /usr/local/etc/v2ray/config.json

		read -p "请输入path（默认"down"）:" urpath
		[ "$urpath" != "" ] && sed -i "18s/down/$urpath/" /usr/local/etc/v2ray/config.json
		urpath="/"$urpath

# 		cat >/usr/local/etc/v2ray/vmess_qr.json << EOF
# 				{
# 					"v": "2",
# 					"ps": "",
# 					"add": "$urdomain",
# 					"port": "443",
# 					"id": "$userid",
# 					"aid": "$alterid",
# 					"net": "ws",
# 					"type": "none",
# 					"host": "",
# 					"path": "$urpath",
# 					"tls": "tls"
# 				} 
# EOF

	echo ""
	echo "*******************"
	echo "请开通端口$port"
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
	echo ""
	echo "  1.Module port                               2.Modify userid"
	echo ""
	read -p "Please input the number you choose:" sub_no

	if [ "$sub_no" = "1" ]; then

		old_port=$(awk 'NR==3 {print $2}' /usr/local/etc/v2ray/config.json)
		old_port=${old_port:0:-1}
		echo "原端口：$old_port"

		read -p "请设置端口号（默认24380）：" port
		[ "$port" != "" ] && sed -i "3s/24380/$port/" /usr/local/etc/v2ray/config.json

		service v2ray stop
		service v2ray start

		new_port=$(awk 'NR==3 {print $2}' /usr/local/etc/v2ray/config.json)
		new_port=${new_port:0:-1}
		echo "新端口：$port"

	elif [ "$sub_no" = "2" ]; then
		old_userid=$(awk 'NR==8 {print$2}' /usr/local/etc/v2ray/config.json)
		old_userid=${old_userid:1:-2}
		echo -e "用户id: $old_userid\n"

		read -s -n1 -p "Press Enter to continue or press Ctrl+C to quit"
		userid=$(cat /proc/sys/kernel/random/uuid)
		sed -i "s/$old_userid/$userid/" /usr/local/etc/v2ray/config.json
		service v2ray stop
		service v2ray start
		new_userid=$(awk 'NR==8 {print$2}' /usr/local/etc/v2ray/config.json)
		new_userid=${new_userid:1:-2}
		echo -e "\n用户id: $new_userid"
	else
	exit 0
	fi

else
exit 0

fi