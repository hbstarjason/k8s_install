apt-get update
apt-get install python-pip -y && pip install shadowsocks

cat >>/etc/shadowsocks.json<<EOF
{
    "server":"67,21,94,192",
    "server_port":45678,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"dongtaiwang.com",
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open": false
}
EOF

sudo nohup sslocal -c /etc/shadowsocks.json &>> /var/log/sslocal.log &

apt-get install privoxy -y

vi /etc/privoxy/config 

listen-address 0.0.0.0:8118
forward-socks5 / localhost:1080 .

systemctl restart privoxy
/etc/init.d/privoxy  restart

export http_proxy=http://localhost:8118  && export https_proxy=http://localhost:8118 

curl ip.gs

#########

sudo apt-get install polipo

cat >> /etc/polipo/config <<EOF
logSyslog = true
logFile = /var/log/polipo/polipo.log
proxyAddress = "0.0.0.0"
proxyPort = 17070
socksParentProxy = "127.0.0.1:7070"
socksProxyType = socks5
allowedClients = 127.0.0.1
EOF

sudo service polipo stop && sudo service polipo start

export http_proxy="http://127.0.0.1:17070" && export http_proxy="http://127.0.0.1:17070"
