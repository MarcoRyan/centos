#!/bin/bash



function save_config(){

	cat >/usr/local/etc/v2ray/vmess_qr.json <<-EOF
			{
				"v": "2",
				"add": "${ip}",
				"port": "${port}",
				"id": "${v2ray_id}",
				"aid": "${alterId}",
				"net": "tcp",
				"type": "none"
				"host": "",
				"path": "",
				"tls": ""
			}
		EOF

}

ip=$(curl -s https://ipinfo.io/ip)
echo "服务器地址：$ip"
port=$(awk 'NR==3 {print $2}' /usr/local/etc/v2ray/config.json)
port=${port%,}
echo "端口：$port"
userid=$(awk 'NR==8 {print $2}' /usr/local/etc/v2ray/config.json)
userid=${userid:1:-2}
echo "用户id: $userid"
alterid=$(awk 'NR==10 {print $2}' /usr/local/etc/v2ray/config.json)
echo "额外id: $alterid" 
echo "传输协议：tcp"
echo "伪装类型：none"
echo "伪装域名："
echo "伪装路径："
echo："底层传输协议："

save_config
