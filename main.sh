#!/bin/bash

function GetIp() {
  MAINIP=$(ip route get 1 | awk -F 'src ' '{print $2}' | awk '{print $1}')
  GATEWAYIP=$(ip route | grep default | awk '{print $3}')
  SUBNET=$(ip -o -f inet addr show | awk '/scope global/{sub(/[^.]+\//,"0/",$4);print $4}' | head -1 | awk -F '/' '{print $2}')
  value=$(( 0xffffffff ^ ((1 << (32 - $SUBNET)) - 1) ))
  NETMASK="$(( (value >> 24) & 0xff )).$(( (value >> 16) & 0xff )).$(( (value >> 8) & 0xff )).$(( value & 0xff ))"
  URIP=$(curl ifconfig.me)
}

# 定义颜色变量, 还记得吧, \033、\e和\E是等价的
RED='\E[1;31m'       # 红
GREEN='\E[1;32m'    # 绿
YELLOW='\E[1;33m'    # 黄
BLUE='\E[1;34m'     # 蓝
PINK='\E[1;35m'     # 粉红
RES='\E[0m'          # 清除颜色
 
 
# 真正使用时, 我们通过echo -e来调用
echo -e  "${RED}Red color${RES}"
echo -e  "${YELLOW}Yelow color${RES}"
echo -e  "${BLUE}Blue color${RES}"
echo -e  "${GREEN}Green color${RES}"
echo -e  "${PINK}Pink color${RES}"

echo "==========================================================================="
echo "Main page:"
echo "Your IP: $URIP"
echo ""
echo -e "  ${YELLOW}1.Install v2ray${RES}                              ${YELLOW}2.Uninstall v2ray${RES}"
echo ""
echo -e "  ${YELLOW}3.Check config.json${RES}                           ${YELLOW}4.Modify userid${RES}"
echo ""
echo -e "  ${YELLOW}5.Download mydd.sh${RES}                            ${YELLOW}6.PASS${RES}"
echo ""
echo -e "  ${YELLOW}7.Install 7zip${RES}                                ${YELLOW}8.PASS${RES}"
echo ""
echo -e "  ${YELLOW}9.Modify SSH Port (for defaut port 22)${RES}        ${YELLOW}a.Install vim and bc${RES}"
echo ""
echo -e "  ${YELLOW}b.Install screen${RES}                              ${YELLOW}c.Install msmtp${RES}"
echo ""
echo -e "  ${YELLOW}d.Set localtime to China zone${RES}                 ${YELLOW}e.Install xfce and vnc${RES}"
echo ""
echo "Written by URLab.xyz, updated on 2021/08/19"
echo "==========================================================================="


read -p "Please input the number you choose:" main_no
if [ "$main_no" = "1" ]; then
wget http://www.urlab.xyz/down/oolnmp.tar.gz
elif [ "$main_no" = "2" ]; then
wget http://www.urlab.xyz/down/openvpn/openvpn.sh
chmod +x openvpn.sh
elif [ "$main_no" = "3" ]; then
wget http://www.urlab.xyz/down/transmission/transmission.sh
chmod +x transmission.sh
elif [ "$main_no" = "4" ]; then
wget http://www.urlab.xyz/down/java/ibm_java.sh
chmod +x ibm_java.sh
elif [ "$main_no" = "5" ]; then
wget http://www.urlab.xyz/down/bb/bbmail.sh
chmod +x bbmail.sh
elif [ "$main_no" = "6" ]; then
wget http://www.urlab.xyz/down/bb/bbmds.sh
chmod +x bbmds.sh
elif [ "$main_no" = "7" ]; then
wget http://www.urlab.xyz/down/7zip/7zip.sh
chmod +x 7zip.sh
elif [ "$main_no" = "8" ]; then
wget http://www.urlab.xyz/down/pptp.sh
chmod +x pptp.sh
elif [ "$main_no" = "9" ]; then
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
elif [ "$main_no" = "a" ]; then
yum -y install vim-enhanced
yum -y install bc
elif [ "$main_no" = "b" ]; then
yum -y install screen
echo ""
echo "screen -S xxx    #creat a new screen named xxx"
echo "screen -r xxx    #recall the screen named xxx"
echo "exit             #shut off the current screen session"
elif [ "$main_no" = "c" ]; then
wget http://sourceforge.net/projects/msmtp/files/msmtp/1.4.25/msmtp-1.4.25.tar.bz2/download
tar xjvf msmtp-1.4.25.tar.gz2
cd msmtp*
./configure
make
make install
echo "......................................................"
echo "msmstp is installed in /usr/local/bin defaultly."
echo "Please modify .muttrc and .msmtprc"
echo "......................................................"
elif [ "$main_no" = "d" ]; then
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
date
elif [ "$main_no" = "e" ]; then
echo ""
echo "this script will install the destktop xfce4.4 and vncserver to your vps with centos 5"
read -n 1 -p "Press any key to continue..."
yum -y groupinstall xfce-4.4
yum -y install vnc vnc-server
cat >>/etc/sysconfg/vncservers <<EOF
VNCSERVERS="1:root"
VNCSERVERARGS[1]="-geometry 800x600"
EOF
vncpasswd
vncserver
cat >/root/.vnc/xstartup <<EOF
#!/bin/sh
/usr/bin/startxfce4
EOF
chmod +x ~/.vnc/xstartup
service vncserver restart
echo ""
echo " if needed, run 'chkconfig vncserver on' to set VNC starting up automatically"

else
exit 0

fi
