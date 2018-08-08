K8S-1.11_install

参考链接

官网地址：

一、环境准备

    # 实验架构
    lab1: master 11.11.11.111
    lab2: node 11.11.11.112
    lab3: node 11.11.11.113
     
    # cat /etc/redhat-release
    CentOS Linux release 7.4.1708 (Core)

二、实验使用的文件：

Vagrantfile和init.sh

    # 所需box文件CentOS-7-x86_64-Vagrant-1801_02.VirtualBox.box
    wget -c http://cloud.centos.org/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1801_02.VirtualBox.box
    vagrant box add CentOS-7-x86_64-Vagrant-1801_02.VirtualBox.box --name centos/7
    
    # 添加box

    # cat <<EOF >  Vagrantfile
     
    # -*- mode: ruby -*-
    # vi: set ft=ruby :
     
    ENV["LC_ALL"] = "en_US.UTF-8"
     
    Vagrant.configure("2") do |config|
        (1..3).each do |i|
          # config.vm.provision "shell", path: "init.sh"
          config.vm.define "lab#{i}" do |node|
            node.vm.box = "centos/7"
            node.ssh.insert_key = false
            node.vm.hostname = "lab#{i}"
            node.vm.network "private_network", ip: "11.11.11.11#{i}"
            # node.vm.synced_folder "~/Desktop/share", "/home/vagrant/share"
            node.vm.provision "shell", path: "init.sh"
            node.vm.provider "virtualbox" do |v|
              v.cpus = 2
              v.customize ["modifyvm", :id, "--name", "lab#{i}", "--memory", "2048"]
            end
          end
        end
    end
     
    EOF

    # cat <<EOF > init.sh
     
    #!/bin/bash
    PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
    export PATH
     
    cat >>/etc/hosts<<EOF
    11.11.11.111 lab1
    11.11.11.112 lab2
    11.11.11.113 lab3
    EOF
     
    echo "nameserver 219.141.136.10">/etc/resolv.conf
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    timedatectl set-timezone Asia/Shanghai
     
    yum install -y wget
    cd /etc/yum.repos.d && mv CentOS-Base.repo CentOS-Base.repo.bak
    wget -O CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    yum clean all && yum makecache
    yum install -y  lrzsz git
    
    systemctl stop firewalld.service && systemctl disable firewalld.service
     
    setenforce 0
    sed -i 's/=enforcing/=disabled/g' /etc/selinux/config
     
    cat >> /etc/sysctl.conf <<EOF
    net.ipv4.ip_forward=1
    EOF
    sysctl -p
     
    echo 'disable swap'
            swapoff -a
            sed -i '/swap/s/^/#/' /etc/fstab
             
    egrep "^docker" /etc/group >& /dev/null
            if [ $? -ne 0 ]
            then
              groupadd docker
            fi
     
            usermod -aG docker vagrant
            rm -rf ~/.docker/
            yum install -y docker.x86_64
    systemctl start docker && systemctl enable docker
     
    cat > /etc/docker/daemon.json <<EOF
    {
      "registry-mirrors" : ["https://de5884ui.mirror.aliyuncs.com"]
    }
    EOF
     
    EOF

    # 以上是通过Vagrant和VirtualBox自动创建虚拟机3台，并进行相应的初始化。
    # 若虚拟机已创建完毕，请做以下初始化。

1. 关闭防火墙和
2. selinux
3. 修改主机名及hosts
4. 设置DNS
5. 更改Yum源
6. 关闭swap
7. 安装docker
8. 配置docker加速器

三、如下操作在所有节点操作：

1. 安装 kubeadm, kubelet 和 kubectl
       # 配置源
       cat <<EOF > /etc/yum.repos.d/kubernetes.repo
       [kubernetes]
       name=Kubernetes
       baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
       enabled=1
       gpgcheck=1
       repo_gpgcheck=1
       gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
       EOF
        
       # 安装
       yum install -y kubelet kubeadm kubectl ipvsadm
2. 配置启动kubelet 

    # 临时禁用selinux
    # 永久关闭 修改/etc/sysconfig/selinux文件设置
    sed -i 's/SELINUX=permissive/SELINUX=disabled/' /etc/sysconfig/selinux
    setenforce 0
     
    # 临时关闭swap
    # 永久关闭 注释/etc/fstab文件里swap相关的行
    swapoff -a
     
    # 开启forward
    # Docker从1.13版本开始调整了默认的防火墙规则
    # 禁用了iptables filter表中FOWARD链
    # 这样会引起Kubernetes集群中跨Node的Pod无法通信
     
    iptables -P FORWARD ACCEPT
     
    # 配置转发相关参数，否则可能会出错
    cat <<EOF >  /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables = 1
    vm.swappiness=0
    EOF
    sysctl --system
     
    # 加载ipvs相关内核模块
    # 如果重新开机，需要重新加载
    modprobe ip_vs
    modprobe ip_vs_rr
    modprobe ip_vs_wrr
    modprobe ip_vs_sh
    modprobe nf_conntrack_ipv4
    lsmod | grep ip_vs
    
    # 配置kubelet使用国内pause镜像
    # 配置kubelet的cgroups
    # 获取docker的cgroups
    DOCKER_CGROUPS=$(docker info | grep 'Cgroup' | cut -d' ' -f3)
    echo $DOCKER_CGROUPS
    cat >/etc/sysconfig/kubelet<<EOF
    KUBELET_EXTRA_ARGS="--cgroup-driver=$DOCKER_CGROUPS --pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google_containers/pause-amd64:3.1"
    EOF
     
    # 启动
    systemctl daemon-reload
    systemctl enable kubelet && systemctl start kubelet

四、如下操作在master节点操作：

1、配置master并初始化

    # 1.11 版本 centos 下使用 ipvs 模式会出问题
    # 参考 https://github.com/kubernetes/kubernetes/issues/65461
     
    # 生成配置文件
    cat >kubeadm-master.config<<EOF
    apiVersion: kubeadm.k8s.io/v1alpha2
    kind: MasterConfiguration
    kubernetesVersion: v1.11.0
    imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers
    api:
      advertiseAddress: 11.11.11.111
     
    controllerManagerExtraArgs:
      node-monitor-grace-period: 10s
      pod-eviction-timeout: 10s
     
    networking:
      podSubnet: 10.244.0.0/16
       
    kubeProxy:
      config:
        # mode: ipvs
        mode: iptables
    EOF
     
    # 提前拉取镜像
    # 如果执行失败 可以多次执行
    kubeadm config images pull --config kubeadm-master.config
     
    # 初始化
    kubeadm init --config kubeadm-master.config

2、配置使用kubectl 

    rm -rf $HOME/.kube
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
     
    # 查看node节点
    kubectl get nodes
     
    # 只有网络插件也安装配置完成之后，才能会显示为ready状态
    # 设置master允许部署应用pod，参与工作负载，现在可以部署其他系统组件
    # 如 dashboard, heapster, efk等
    kubectl taint nodes --all node-role.kubernetes.io/master-

3、配置使用网络插件

    # 下载配置
    mkdir flannel && cd flannel
    wget https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml
     
    # 修改配置
    # 此处的ip配置要与上面kubeadm的pod-network一致
      net-conf.json: |
        {
          "Network": "10.244.0.0/16",
          "Backend": {
            "Type": "vxlan"
          }
        }
     
    # 修改镜像
    image: registry.cn-shanghai.aliyuncs.com/gcr-k8s/flannel:v0.10.0-amd64
     
    docker pull registry.cn-shanghai.aliyuncs.com/gcr-k8s/flannel:v0.10.0-amd64 && \
    docker tag registry.cn-shanghai.aliyuncs.com/gcr-k8s/flannel:v0.10.0-amd64 quay.io/coreos/flannel:v0.10.0-amd64
     
    # 如果Node有多个网卡的话，参考flannel issues 39701，
    # https://github.com/kubernetes/kubernetes/issues/39701
    # 目前需要在kube-flannel.yml中使用--iface参数指定集群主机内网网卡的名称，
    # 否则可能会出现dns无法解析。容器无法通信的情况，需要将kube-flannel.yml下载到本地，
    # flanneld启动参数加上--iface=<iface-name>
        containers:
          - name: kube-flannel
            image: registry.cn-shanghai.aliyuncs.com/gcr-k8s/flannel:v0.10.0-amd64
            command:
            - /opt/bin/flanneld
            args:
            - --ip-masq
            - --kube-subnet-mgr
            - --iface=eth1
     
    # 启动
    kubectl apply -f kube-flannel.yml
     
    # 查看
    kubectl get pods --namespace kube-system
    kubectl get svc --namespace kube-system



五、如下操作在node节点操作：

    # 此命令为初始化master成功后返回的结果
    kubeadm join 11.11.11.111:6443 --token ocj4qp.qzshbzjpv095e418 --discovery-token-ca-cert-hash sha256:9ea06d48a41289b538aadb2103bbe794b3d2cb70740e522bd97ac6ef129e11e6

六、测试

    kubectl run nginx --replicas=2 --image=nginx:alpine --port=80
    kubectl expose deployment nginx --type=NodePort --name=example-service-nodeport
    kubectl expose deployment nginx --name=example-service
     
    kubectl get deploy
    kubectl get pods
    kubectl get svc
    kubectl describe svc example-service
     
    kubectl run curl --image=radial/busyboxplus:curl -i --tty
    nslookup kubernetes
    nslookup example-service
    curl example-service
     
     
    # 10.96.100.22 为查看svc时获取到的clusterip
    curl "10.96.100.22"
     
    # 32223 为查看svc时获取到的 nodeport
    http://11.11.11.112:32058/
    http://11.11.11.113:32058/
     
    # 清理删除
    kubectl delete svc example-service example-service-nodeport
    kubectl delete deploy nginx curl

七、小技巧

    # 忘记初始master节点时的node节点加入集群命令
    # 简单方法
    kubeadm token create --print-join-command
     
    # 第二种方法
    token=$(kubeadm token generate)
    kubeadm token create $token --print-join-command --ttl=0


