## 基本使用

```bash
# Install docker
此处省略，如果不会，后面建议不用看了。

# Install kind
# https://kind.sigs.k8s.io/

$ curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.8.1/kind-linux-amd64 && \
  chmod +x ./kind && \
  mv ./kind /usr/local/bin/kind 
$ kind --version 
kind version 0.8.1

# Install Kubectl
$ wget https://mirror.azure.cn/kubernetes/kubectl/v1.18.2/bin/linux/amd64/kubectl && \
  sudo chmod +x ./kubectl && \
  sudo mv ./kubectl /usr/local/bin/kubectl && \
  kubectl version --client 
Client Version: version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.2", GitCommit:"52c56ce7a8272c798dbc29846288d7cd9fbae032", GitTreeState:"clean", BuildDate:"2020-04-16T11:56:40Z", GoVersion:"go1.13.9", Compiler:"gc", Platform:"linux/amd64"}

# Install cluster
$ kind create cluster --name hbstarjason
Creating cluster "hbstarjason" ...
 ✓ Ensuring node image (kindest/node:v1.18.2) � 
 ✓ Preparing nodes �  
 ✓ Writing configuration � 
 ✓ Starting control-plane �️ 
 ✓ Installing CNI � 
 ✓ Installing StorageClass � 
Set kubectl context to "kind-hbstarjason"
You can now use your cluster with:

kubectl cluster-info --context kind-hbstarjason

Thanks for using kind! �

$ kubectl cluster-info --context kind-hbstarjason
Kubernetes master is running at https://127.0.0.1:46446
KubeDNS is running at https://127.0.0.1:46446/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

$ kubectl get po  --all-namespaces 
NAMESPACE            NAME                                                READY   STATUS    RESTARTS   AGE
kube-system          coredns-66bff467f8-7ncdm                            1/1     Running   0          9m
kube-system          coredns-66bff467f8-vpngk                            1/1     Running   0          9m
kube-system          etcd-hbstarjason-control-plane                      1/1     Running   0          9m9s
kube-system          kindnet-7bt9c                                       1/1     Running   0          9m
kube-system          kube-apiserver-hbstarjason-control-plane            1/1     Running   0          9m9s
kube-system          kube-controller-manager-hbstarjason-control-plane   1/1     Running   0          9m9s
kube-system          kube-proxy-snpd6                                    1/1     Running   0          9m
kube-system          kube-scheduler-hbstarjason-control-plane            1/1     Running   0          9m8s
local-path-storage   local-path-provisioner-bd4bb6b75-dlqxr              1/1     Running   0          9m

# 至此，一个单节点的k8s直接就running，该有的都有了。

# 快速删除
$ kind delete  cluster --name hbstarjason
```



```bash
# 创建一个3节点的集群，1个master，2个node

$ cat >>  hbstarjason--multi-node.yaml <<EOF
kind: Cluster
apiVersion: kind.sigs.k8s.io/v1alpha3
nodes:
- role: control-plane
- role: worker
- role: worker
EOF

$ kind create cluster --config hbstarjason--multi-node.yaml --name hbstarjason--multi-node

# 以下步骤与单节点一样，省略。

# 查看集群
$ kubectl get node
NAME                                    STATUS   ROLES    AGE    VERSION
hbstarjason--multi-node-control-plane   Ready    master   103s   v1.18.2
hbstarjason--multi-node-worker          Ready    <none>   71s    v1.18.2
hbstarjason--multi-node-worker2         Ready    <none>   70s    v1.18.2
```



```bash
# 创建一个高可用集群，3个master，3个node

$ cat >> hbstarjason-ha.yaml <<EOF
kind: Cluster
apiVersion: kind.sigs.k8s.io/v1alpha3
kubeadmConfigPatches:
- |
  apiVersion: kubeadm.k8s.io/v1beta2
  kind: ClusterConfiguration
  metadata:
    name: config
  networking:
    serviceSubnet: 10.0.0.0/16
  imageRepository: registry.aliyuncs.com/google_containers
  nodeRegistration:
    kubeletExtraArgs:
      pod-infra-container-image: registry.aliyuncs.com/google_containers/pause:3.1
- |
  apiVersion: kubeadm.k8s.io/v1beta2
  kind: InitConfiguration
  metadata:
    name: config
  networking:
    serviceSubnet: 10.0.0.0/16
  imageRepository: registry.aliyuncs.com/google_containers
nodes:
- role: control-plane
- role: control-plane
- role: control-plane
- role: worker
- role: worker
- role: worker
EOF

$ kind create cluster --name hbstarjason-ha --config hbstarjason-ha.yaml
# 以下步骤与单节点一样，省略。

# 查看集群
$ kubectl get node
NAME                            STATUS   ROLES    AGE    VERSION
hbstarjason-ha-control-plane    Ready    master   3m7s   v1.18.2
hbstarjason-ha-control-plane2   Ready    master   2m2s   v1.18.2
hbstarjason-ha-control-plane3   Ready    master   69s    v1.18.2
hbstarjason-ha-worker           Ready    <none>   56s    v1.18.2
hbstarjason-ha-worker2          Ready    <none>   55s    v1.18.2
hbstarjason-ha-worker3          Ready    <none>   53s    v1.18.2

# 3分钟启动一个高可用集群，意外惊喜~~
```



## 进阶使用

```bash
# 已自带StorageClass
$ kubectl get sc 
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
standard (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  78m
```

```bash
# 创建Ingress
# https://kind.sigs.k8s.io/docs/user/ingress/

$ 
```

