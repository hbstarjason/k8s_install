# Ubuntu 14.04

mv /etc/apt/sources.list /etc/apt/sources.list.bak

cat > /etc/apt/sources.list << EOF 
deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
EOF

# https://docs.snapcraft.io/installing-snap-on-ubuntu
apt-get update && apt-get install snapd

# https://microk8s.io/
sudo snap install microk8s --classic

# https://github.com/canonical-labs/cicd-microk8s-basic

# sudo snap install multipass --beta --classic

# install helm 
sudo snap install helm --classic

####

# install kubectl 
sudo snap install kubectl --classic
kubectl version

curl -Lo minikube https://storage.googleapis.com/minikube/releases/v1.1.1/minikube-linux-amd64 && \
chmod +x minikube && \
sudo cp minikube /usr/local/bin/ && rm minikube
minikube start --vm-driver=none
minikube dashboard
