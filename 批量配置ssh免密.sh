#!/bin/sh
#des: 批量部署SSH免密登录服务器
#by balladpanda<balladpanda@gmail.com>
#date: 2020年11月10日14:39:21


# 安装依赖,当前服务器安装即可
if command -v expect > /dev/null; then
 exit 0
else
    yum install expect -y > /dev/null
fi
# 写个用于自动生成密钥对的函数
auto_keygen (){
    /usr/bin/expect<<EOF
    set timeout 30
    spawn   ssh-keygen
    expect     {
        ".ssh/id_rsa)"       { send    "\n";  exp_continue }
        "Overwrite (y/n)?"   { send    "y\n"; exp_continue }
        "no passphrase):"    { send    "\n";  exp_continue }
        "again:"             { send    "\n";  exp_continue }
    }
EOF
}

# 写个自动免密登录的函数
send_key () {
# 修改成自己服务器的密码  
pwd=xxxxxx1234567
# 开始执行
    /usr/bin/expect <<EOF
    set timeout 30

# 发送公钥给对方服务器
    spawn ssh-copy-id root@$1
    expect {
        "yes/no" { send "yes\n"; exp_continue }
        "password:" { send "${pwd}\n"; exp_continue } 
    }
expect eof
EOF
}

# 定义一个变量，其值是当前用户的公钥文件
pub_key_file=$HOME/.ssh/id_rsa.pub

# 假如公钥文件不存在，说明需要创建密钥对
if [ ! -f ${pub_key_file} ];then
    auto_keygen
fi

# 循环一个存放 ip 地址的文件，并且把每个 IP地址传递给 函数
for ip in $(cat ./ip_lsit.txt)
do
   send_key $ip
done