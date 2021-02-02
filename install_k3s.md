# K3s试用

```sh
# https://k3s.io/
# 安装
$ curl -sfL https://get.k3s.io | sh -
[INFO]  Finding latest release
[INFO]  Using v0.5.0 as release
[INFO]  Downloading hash https://github.com/rancher/k3s/releases/download/v0.5.0/sha256sum-amd64.txt
[INFO]  Downloading binary https://github.com/rancher/k3s/releases/download/v0.5.0/k3s
[INFO]  Verifying binary download
[INFO]  Installing k3s to /usr/local/bin/k3s
[INFO]  Creating /usr/local/bin/kubectl symlink to k3s
[INFO]  Creating /usr/local/bin/crictl symlink to k3s
[INFO]  Creating killall script /usr/local/bin/k3s-killall.sh
[INFO]  Creating uninstall script /usr/local/bin/k3s-uninstall.sh
[INFO]  env: Creating environment file /etc/systemd/system/k3s.service.env
[INFO]  systemd: Creating service file /etc/systemd/system/k3s.service
[INFO]  systemd: Enabling k3s unit
Created symlink from /etc/systemd/system/multi-user.target.wants/k3s.service to /etc/systemd/system/k3s.service.
[INFO]  systemd: Starting k3s
$ k3s kubectl get node
NAME     STATUS   ROLES    AGE   VERSION
host01   Ready    <none>   14s   v1.14.1-k3s.4
$ k3s kubectl get pod --all-namespaces
NAMESPACE     NAME                         READY   STATUS      RESTARTS   AGE
kube-system   coredns-695688789-zr2gz      1/1     Running     0          5m48s
kube-system   helm-install-traefik-kwv7g   0/1     Completed   0          5m48s
kube-system   svclb-traefik-cnf4w          2/2     Running     0          5m29s
kube-system   traefik-55bd9646fc-b4nvl     1/1     Running     0          5m29s

# 创建应用
$ k3s kubectl run nginx --image nginx:alpine --replicas 3
kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead.
deployment.apps/nginx created
$ k3s kubectl get pod --all-namespaces
NAMESPACE     NAME                         READY   STATUS      RESTARTS   AGE
default       nginx-546c47b569-4cf2j       1/1     Running     0          62s
default       nginx-546c47b569-549kr       1/1     Running     0          62s
default       nginx-546c47b569-fftfk       1/1     Running     0          62s
kube-system   coredns-695688789-zr2gz      1/1     Running     0          9m15s
kube-system   helm-install-traefik-kwv7g   0/1     Completed   0          9m15s
kube-system   svclb-traefik-cnf4w          2/2     Running     0          8m56s
kube-system   traefik-55bd9646fc-b4nvl     1/1     Running     0          8m56s

$ k3s kubectl expose deployment nginx \
 --port 80 \
 --target-port 80 \
 --type ClusterIP \
 --selector=run=nginx \
 --name nginx
 
 service/nginx exposed
 
$ k3s kubectl get svc --all-namespaces
NAMESPACE     NAME         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)  AGE
default       kubernetes   ClusterIP      10.43.0.1       <none>        443/TCP  14m
default       nginx        ClusterIP      10.43.121.176   <none>        80/TCP  53s
kube-system   kube-dns     ClusterIP      10.43.0.10      <none>        53/UDP,53/TCP,9153/TCP  14m
kube-system   traefik      LoadBalancer   10.43.200.231   172.17.0.34   80:32447/TCP,443:30612/TCP  13m 

$ export CLUSTER_IP=$(k3s kubectl get svc/nginx -o go-template='{{(index .spec.clusterIP)}}')
$ echo CLUSTER_IP=$CLUSTER_IP

# 连接测试
$ lynx $CLUSTER_IP:80 

# https://github.com/rancher/local-path-provisioner
# Get Local Path Provisioner (local-path)
$ curl -LO  https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml

# Install 
$ kubectl apply -f local-path-storage.yaml

# Make local-path default storage class
$ kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Cleanup 
$ rm local-path-storage.yaml

$ kubectl get sc

```

#### 简单试用完毕，一个微型k8s集群瞬间搭建完毕，很酸爽！赶脚与另外两个项目很类似：
1、kind（https://kind.sigs.k8s.io/）
2、Microk8s （https://microk8s.io/）


```sh
2021-2-2 update 
$ curl -sfL https://get.k3s.io | sh -
$ export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
$ kubectl get pods --all-namespaces

$ wget https://github.com/k3s-io/k3s/releases/download/v1.20.2%2Bk3s1/k3s 
$ nohup sudo k3s server &
```
