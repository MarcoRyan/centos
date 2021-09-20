#!/bin/bash

# 定义颜色变量, 还记得吧, \033、\e和\E是等价的
RED='\E[1;31m'       # 红
GREEN='\E[1;32m'    # 绿
YELLOW='\E[1;33m'    # 黄
BLUE='\E[1;34m'     # 蓝
PINK='\E[1;35m'     # 粉红
RES='\E[0m'          # 清除颜色

[[ $(id -u) != 0 ]] && echo -e " 请使用 ${YELLOW}root ${RES}用户运行 ${RED}~(^_^) ${RES}" && exit 1

function GetIp() {
  MAINIP=$(ip route get 1 | awk -F 'src ' '{print $2}' | awk '{print $1}')
  GATEWAYIP=$(ip route | grep default | awk '{print $3}')
  SUBNET=$(ip -o -f inet addr show | awk '/scope global/{sub(/[^.]+\//,"0/",$4);print $4}' | head -1 | awk -F '/' '{print $2}')
  value=$(( 0xffffffff ^ ((1 << (32 - $SUBNET)) - 1) ))
  NETMASK="$(( (value >> 24) & 0xff )).$(( (value >> 16) & 0xff )).$(( (value >> 8) & 0xff )).$(( value & 0xff ))"
  URIP=$(curl -s https://ipinfo.io/ip)
}
function install_bbr() {
	local test1=$(sed -n '/net.ipv4.tcp_congestion_control/p' /etc/sysctl.conf)
	local test2=$(sed -n '/net.core.default_qdisc/p' /etc/sysctl.conf)
	if [[ $test1 == "net.ipv4.tcp_congestion_control = bbr" && $test2 == "net.core.default_qdisc = fq" ]]; then
		echo
		echo -e "${GREEN} BBR 已经启用啦...无需再安装${RES}"
		echo
	else
		[[ ! $enable_bbr ]] && wget --no-check-certificate -O /opt/bbr.sh https://github.com/teddysun/across/raw/master/bbr.sh && chmod 755 /opt/bbr.sh && /opt/bbr.sh
	fi
}

GetIp

# ip_info=$(curl ip.gs/json)
# ip_ip=$(echo $ip_info | jq .ip)
# ip_country=$(echo $ip_info | jq .country)
# ip_region=$(echo $ip_info | jq .region_name)
# ip_city=$(echo $ip_info | jq .city)

clear
echo ""
echo "==========================================================================="
echo -e "${RED}Main page:${RES}"
echo -e "${GREEN}Your IP: $MAINIP${RES}"
echo ""
echo -e "  ${YELLOW}1.DD system${RES}                                   ${YELLOW}2.Install bbr${RES}"
echo ""
echo -e "  ${YELLOW}3.Install bt Panel${RES}                            ${YELLOW}4.Install v2ray${RES}"
echo ""
echo -e "  ${YELLOW}5.Modify SSH Port (for defaut port 22)${RES}        ${YELLOW}6.Unixbech一键跑分${RES}"
echo ""
echo -e "  ${YELLOW}7.Install docker${RES}                              ${YELLOW}8.Upgrade sqlite3${RES}" 
echo ""
echo -e "  ${YELLOW}9.Set localtime to China zone${RES}                 ${YELLOW}10.VPS info${RES}"
echo ""
echo -e " ${YELLOW}11.Test speed (bench.sh)${RES}                       ${YELLOW}12.Install python3.9${RES}"
echo ""
echo -e "${RED}Written by Richard, updated on 2021/08/20${RES}"
echo "==========================================================================="

echo ""
read -p "Please input the number you choose: " main_no

if [ "$main_no" = "1" ]; then
	wget https://github.com/hityne/centos/raw/main/mydd.sh && chmod a+x mydd.sh && bash mydd.sh
elif [ "$main_no" = "2" ]; then
	install_bbr
elif [ "$main_no" = "3" ]; then
	yum install -y wget && wget -O install.sh http://download.bt.cn/install/install_6.0.sh && sh install.sh
elif [ "$main_no" = "4" ]; then
	wget https://raw.githubusercontent.com/hityne/centos/ur/v2ray.sh && chmod a+x v2ray.sh && bash v2ray.sh
elif [ "$main_no" = "5" ]; then
	echo ""
	echo "Please input the ssh port you want to use"
	read -p "Please input the port you select for SSH login: " ssh_port
	echo "=========================================="
	echo SSH port="$ssh_port"
	echo "==========================================="
	echo ""
	#Break here
	read -n 1 -p "Press any key to continue..."
	sed -i 's/#Port 22/Port '$ssh_port'/g' /etc/ssh/sshd_config
	service sshd restart
	echo""
	echo "Service sshd has been restarted. Please use the new SSH port to login."
elif [ "$main_no" = "6" ]; then
	wget --no-check-certificate https://github.com/teddysun/across/raw/master/unixbench.sh && chmod +x unixbench.sh && ./unixbench.sh
elif [ "$main_no" = "7" ]; then
	curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
	echo ""
	echo "Please run 'service docker start' to start docker service."
	echo "Or run 'systemctl enable docker' to make docker autostart when the system reboots."
elif [ "$main_no" = "8" ]; then
	wget https://github.com/hityne/centos/raw/main/upgrade-sqlite3.sh && chmod a+x upgrade-sqlite3.sh && bash upgrade-sqlite3.sh
	
elif [ "$main_no" = "9" ]; then
	rm -rf /etc/localtime
	ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	date -R
elif [ "$main_no" = "10" ]; then
	echo ""
	echo -e "${BLUE}[1]系统版本号：${RES}"
	cat /etc/redhat-release
	echo ""
	echo -e "${BLUE}[2]系统内核：${RES}"
	uname -r
	echo ""
	echo -e "${BLUE}[3]查看BBR是否启动：${RES}"
	sysctl net.ipv4.tcp_congestion_control
	echo ""
	echo -e "${BLUE}[4]上次启动时间：${RES}"
	date -d "$(awk -F. '{print $1}' /proc/uptime) second ago" +"%Y-%m-%d %H:%M:%S"
	echo ""
	echo -e "${BLUE}[5]系统运行时间：${RES}"
	cat /proc/uptime| awk -F. '{run_days=$1 / 86400;run_hour=($1 % 86400)/3600;run_minute=($1 % 3600)/60;run_second=$1 % 60;printf("%d天%d时%d分%d秒\n",run_days,run_hour,run_minute,run_second)}'
	echo ""
	echo -e "${BLUE}[7]内存信息：${RES}"
	info_free=$(free -m)
	echo $info_free | awk '{print $7 "\t"$9"/" $8}'
	echo $info_free | awk '{print $14 "\t"$16"/" $15}'
	echo ""
	echo -e "${BLUE}[8]硬盘信息：${RES}"
	df -h
	echo ""
	echo -e "${BLUE}[9]防火墙状态：${RES}"
	firewall-cmd --state
	echo ""
	echo -e "${BLUE}[10]SELinux状态：${RES}"
	/usr/sbin/sestatus -v
	echo ""
	echo -e "${BLUE}[11]上次登录信息：${RES}"
	last | awk 'NR==2'
	echo ""
	
elif [ "$main_no" = "11" ]; then	
	wget -qO- bench.sh | bash

elif [ "$main_no" = "12" ]; then	
	wget https://raw.githubusercontent.com/hityne/centos/main/install_python3.sh && chmod +x install_python3.sh && bash install_python3.sh	
	
else
exit 0

fi
