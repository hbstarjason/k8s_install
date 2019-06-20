#!/bin/bash

# wget https://raw.githubusercontent.com/hbstarjason/k8s_install/master/deploy-docker_and_compose.sh 

if [[ "$(whoami)" != "root" ]]; then
	echo "please run this script as root ." >&2
	exit 1
fi

echo -e "\033[31m 这个是安装docker和docker-compose的脚本！Please continue to enter or ctrl+C to cancel \033[0m"
sleep 5

#install docker

# curl -fLsS https://get.docker.com/ | sh
# curl -sSL https://get.daocloud.io/docker | sh
# 

install_docker() {
	yum install -y yum-utils device-mapper-persistent-data lvm2
	 yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
	 yum-config-manager --enable docker-ce-edge
	yum-config-manager --enable docker-ce-test
	yum-config-manager --disable docker-ce-edge
	yum install docker-ce -y
	systemctl start docker
	systemctl enable docker
	echo "docker install succeed!!"
}

#install_docker_compace

# wget  https://github.com/docker/compose/releases/download/1.24.0/docker-compose-Linux-x86_64 && mv docker-compose-Linux-x86_64 /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && docker-compose --version
 

install_docker_compose() {

COMPOSE_VESION="1.24.0"

curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VESION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose 
docker-compose --version
echo "docker-compose install succeed!!"
}

main(){

 install_docker
 install_docker_compose

}
main > ./setup.log 2>&1
