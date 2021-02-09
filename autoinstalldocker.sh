#!/bin/sh
#des: auto install docker  and setting os env
#by balladpanda<balladpanda@gmail.com>
#date: 2019年10月27日12:47:02

#定义配置变量
website='www.baidu.com'
os_repo='http://mirrors.aliyun.com/repo/Centos-7.repo'
docker_repo='http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo'
docker_version='18.09.9'
docker_mirros='https://xad6i9zy.mirror.aliyuncs.com'


#判断执行用户是否为root
function checkExecuteUser()
{
    if [ `whoami` != "root" ];then
        return 1
    fi
}

#判断系统是否是中文


#function: 获取系统的位数, 1 == 64, 0 == 32
getOsBit()
{
    local bitcontent="`uname -a`"
    if [ "`echo $bitcontent | grep "x86_64"`" != "" ]; then
        return 1
    fi
    #增加了对i386、i586和i686的检查
    if [ "`echo $bitcontent | grep "x86"`"  != "" ] \
    || [ "`echo $bitcontent | grep "i386"`" != "" ] \
    || [ "`echo $bitcontent | grep "i586"`" != "" ] \
    || [ "`echo $bitcontent | grep "i686"`" != "" ]; then
        return 0
    fi
}
    
#判断网络是否通畅
function checkNetwork()
{
    #超时时间
    local timeout=1
    #目标网站
    local target=$website
    #获取响应状态码
    local ret_code=`curl -I -s --connect-timeout ${timeout} ${target} -w %{http_code} | tail -n1`
    if [ "x$ret_code" != "x200" ];then
        return 1
    fi
}

#修改系统配置
function osConfig()
{
open_files=`ulimit -n`
#禁用SElinux
setenforce 0 > /dev/null 2>&1

if [ $open_files -eq 1024 ]; then

tee >> /etc/systemd/system.conf <<EOF
#脚本追加
DefaultLimitCORE=infinity
DefaultLimitNOFILE=655350
DefaultLimitNPROC=655350
EOF

tee >> /etc/security/limits.conf <<EOF
#脚本追加
*    soft    nofile   655350
*    hard    nofile   655350
*    soft    nproc    655350
*    hard    nproc    655350
EOF

sed -i 's/4096/40960/'  /etc/security/limits.d/20-nproc.conf > /dev/null 2>&1

#系统内核优化
tee >> /etc/sysctl.conf  <<EOF
#脚本追加
vm.swappiness = 0
net.core.netdev_max_backlog = 400000
net.core.optmem_max = 10000000
net.core.rmem_default = 10000000
net.core.rmem_max = 10000000
net.core.somaxconn = 100000
net.core.wmem_default = 11059200
net.core.wmem_max = 11059200
net.ipv4.tcp_synack_retries=2
net.ipv4.tcp_max_orphans=16384
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.all.arp_announce=2
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_congestion_control = bic
net.ipv4.tcp_window_scaling = 0
net.ipv4.tcp_ecn = 0
net.ipv4.tcp_sack = 1
net.ipv4.tcp_max_tw_buckets = 20000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_keepalive_time = 1800
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.netfilter.ip_conntrack_max=204800
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.inet.udp.checksum=1
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

#生效配置
sysctl -p > /dev/null 2>&1
fi
}

#添加docker安装加速镜像源
function installYumMirros()
{
    echo -e "\033[33m开始安装docker介质加速安装镜像源 \033[0m"
    #安装软件依赖包
    yum-config-manager --add-repo $docker_repo  > /dev/null 2>&1
    #安装阿里yum源
    wget -O /etc/yum.repos.d/Centos-Base.repo $os_repo > /dev/null 2>&1
    yum install epel-release -y > /dev/null 2>&1

    if [ $? -eq 0 ] ;then
        echo -e " Docker介质加速安装镜像源成功" "\033[32m Success \033[0m"
    else
        echo -e " Docker介质加速安装镜像源失败，五秒后自动退出脚本" "\033[31m Failure \033[0m"
        sleep 5
        exit
    fi
}

#install docker
function installDocker()
{
    echo -e "\033[33m开始安装DockerCE \033[0m"
    echo -e  " 介质下载进行时..."
    #卸载残留版本
    yum remove docker \
        docker-ce* \
        docker-client \
        docker-client-latest \
        docker-common \
        docker-latest \
        docker-latest-logrotate \
        docker-logrotate \
        docker-engine -y  > /dev/null 2>&1
    rm -rf /etc/docker/* > /dev/null 2>&1
    #开始安装
    yum install  yum-utils device-mapper-persistent-data lvm2 -y > /dev/null 2>&1
    yum install docker-ce-$docker_version docker-ce-cli-$docker_version containerd.io  -y  > /dev/null 2>&1
    if [ $? -eq 0 ];then
        echo -e " DockerCE安装成功" "\033[31m Success \033[0m"
        ##开启启动
        systemctl enable docker > /dev/null 2>&1
        #启动应用
        systemctl restart firewalld > /dev/null 2>&1
        systemctl enable firewalld > /dev/null 2>&1
        systemctl start docker  > /dev/null 2>&1
        status=`systemctl status docker|grep 'Active'|awk -F[" "]+ '{print $3}'`
        if [ $status = "active" ];then
            echo -e " DockerCE启动成功" "\033[31m Success \033[0m"
        else
            echo -e " DockerCE启动失败，五秒后自动退出脚本" "\033[31m Failure \033[0m"
            sleep 5
            exit
        fi
    else
        echo -e " DockerCE安装失败，五秒后自动退出脚本" "\033[31m Failure \033[0m"
        sleep 5
        exit
    fi
}

#install docker-compose
function installDockerCompose()
{
    echo -e "\033[33m开始安装docker-compose \033[0m"
    echo -e  " 下载进行时..."
    #下载命令（GitHub下载受网络影响较大）
    # curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose > /dev/null 2>&1
    # chmod +x /usr/local/bin/docker-compose > /dev/null 2>&1
    # ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose > /dev/null 2>&1
    #pip方式安装
    yum install python-pip -y > /dev/null 2>&1
    pip install docker-compose -i https://pypi.tuna.tsinghua.edu.cn/simple > /dev/null 2>&1
    #判断是否成功
    if [ $? -eq 0 ];then
        echo -e " docker-compose安装成功" "\033[31m Success \033[0m"
    else
        echo -e " docker-compose安装失败，五秒后自动退出脚本" "\033[31m Failure \033[0m"
        sleep 5
        exit
    fi
}

#setting docker image mirror
function installImageMirros()
{
    echo -e "\033[33m开始安装Docker镜像加速器 \033[0m"
    mkdir -p /etc/docker > /dev/null 2>&1
tee /etc/docker/daemon.json > /dev/null 2>&1 <<'EOF'
{
"registry-mirrors": ["docker_mirros"],
"insecure-registries":["registry.xinbeiting.com"]
}

EOF
    sed -i "s!docker_mirros!$docker_mirros!" /etc/docker/daemon.json
    #重启daemon配置生效
    systemctl daemon-reload > /dev/null 2>&1
    #重启docker
    systemctl restart docker > /dev/null 2>&1
    if [ -f "/etc/docker/daemon.json" ];then
        echo -e " Docker镜像加速器安装成功" "\033[31m Success \033[0m"
        status=`systemctl status docker|grep 'Active'|awk -F[" "]+ '{print $3}'`
        if [ $status = "active" ];then
            echo -e " Docker重启成功" "\033[31m Success \033[0m"
        else
            echo -e " Docker重启失败，五秒后自动退出脚本" "\033[31m Failure \033[0m"
            sleep 5
            exit
        fi
    else
        echo -e " Docker镜像加速器安装失败，五秒后自动退出脚本" "\033[31m Failure \033[0m"
        sleep 5
        exit
    fi

    
}

####### 主界面 #######
run()
{
    #检查执行用户
    checkExecuteUser
    local checkExecuteUser=$?
    if [[ $checkExecuteUser -eq 1 ]]; then
        echo -e "\033[31m 警告:您需要在root用户下运行此脚本，请切换用户后再次运行!\033[0m"
        exit 1
    fi
    #优化系统配置
    osConfig
    #检查网络
    checkNetwork
    local checkNetwork=$?
    if [ $checkNetwork -eq 1 ]; then
        echo -e "\033[31m 警告:网络异常，请检查网络后重新运行！\033[0m"
        exit 1
    fi
    #判断操作系统位数
    getOsBit
    local get_Os_Bit=$?
    if [ $get_Os_Bit -eq 0 ]; then
        echo -e "\033[31m 警告:安装包不支持32操作系统! \033[0m"
        exit 1
    fi

#使用说明
echo -e "\033[33m          《服务器容器环境初始化脚本》使用说明          \033[0m"
echo -e "\033[36m #######################################################\033[0m"
echo -e "\033[36m ## 仅适用于全新的系统环境，以及CentOS7.X及以上系统!  ##\033[0m"
echo -e "\033[36m ## 在线安装，暂不支持离线安装                        ##\033[0m"
echo -e "\033[36m ## 默认安装的版本:                                   ##\033[0m"
echo -e "\033[36m ##  docker-ce:$docker_version                                ##\033[0m"
echo -e "\033[36m ##  docker-ce-cli:$docker_version                            ##\033[0m"
echo -e "\033[36m ##  docker-compose:1.24.1                            ##\033[0m"
echo -e "\033[36m #######################################################\033[0m"
#选择
echo ""
echo -e "\033[32m 1: 开始安装 \033[0m"
echo ""
echo -e "\033[32m 2: 退出脚本 \033[0m"
echo ""
read -p  "请输入对应数字后按回车开始执行脚本: " install
if [ "$install" == "1" ];then
    installYumMirros

    installDocker
    
    installImageMirros
    
    installDockerCompose

    echo ""
    echo -e "\033[33m## 安装完成，部分系统配置需重启生效，请重启服务器！##\033[0m"
    echo ""
else
    echo -e "\033[31m 我们江湖再见 \033[0m"
    exit
fi
}
#运行
run

