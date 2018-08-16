# 安装Helm

## 官方地址：<https://helm.sh/>

## 一、安装客户端

```bash
# 通常，我们将 Helm 客户端安装在能够执行 kubectl 命令的节点上，只需要下面一条命令：
$ curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
```

```bash
# 直接下载包安装
$ wget -c https://kubernetes-helm.storage.googleapis.com/helm-v2.9.1-linux-amd64.tar.gz
$ tar -xvf helm-v2.9.1-linux-amd64.tar.gz
$ mv linux-amd64/helm /usr/local/bin/

# 执行验证
$ /usr/local/bin/helm version
Client: &version.Version{SemVer:"v2.9.1", GitCommit:"20adb27c7c5868466912eebdf6664e7390ebe710", GitTreeState:"clean"}
Error: cannot connect to Tiller
 
# 目前只能查看到客户端的版本，因为服务器还没有安装。
```

## 二、安装服务器端

```bash
# Tiller 服务器安装非常简单，只需要执行 helm init
$ helm init
Creating /root/.helm
Creating /root/.helm/repository
Creating /root/.helm/repository/cache
Creating /root/.helm/repository/local
Creating /root/.helm/plugins
Creating /root/.helm/starters
Creating /root/.helm/cache/archive
Creating /root/.helm/repository/repositories.yaml
Adding stable repo with URL: https://kubernetes-charts.storage.googleapis.com
Error: Looks like "https://kubernetes-charts.storage.googleapis.com" is not a valid chart repository or cannot be reached: Get https://kubernetes-charts.storage.googleapis.com/index.yaml: dial tcp 172.217.160.112:443: i/o timeout
```

```bash
# helm init  在缺省配置下， Helm 会利用 "gcr.io/kubernetes-helm/tiller" 镜像在Kubernetes集群上安装配置 Tiller；并且利用 "https://kubernetes-charts.storage.googleapis.com" 作为缺省的 stable repository 的地址。由于在国内可能无法访问 "gcr.io", "storage.googleapis.com" 等域名，阿里云容器服务为此提供了镜像站点。

$ /usr/local/bin/helm init --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.9.1 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
 
Creating /root/.helm/repository/repositories.yaml
Adding stable repo with URL: https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
Adding local repo with URL: http://127.0.0.1:8879/charts
$HELM_HOME has been configured at /root/.helm.
 
Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.
 
Please note: by default, Tiller is deployed with an insecure 'allow unauthenticated users' policy.
For more information on securing your installation see: https://docs.helm.sh/using_helm/#securing-your-helm-installation
Happy Helming!
```

```bash
# 验证
# Tiller 本身也是作为容器化应用运行在 Kubernetes Cluster 中的
$ kubectl get --namespace=kube-system svc tiller-deploy
NAME            TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)     AGE
tiller-deploy   ClusterIP   10.97.46.69   <none>        44134/TCP   2h
 
$ kubectl get --namespace=kube-system deployment tiller-deploy
NAME            DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
tiller-deploy   1         1         1            1           2h
 
$ kubectl get --namespace=kube-system pods |grep tiller-deploy
tiller-deploy-98f7f7564-bt82m   1/1       Running   0          1h 
 
# helm version 已经能够查看到服务器的版本信息
$ helm version
Client: &version.Version{SemVer:"v2.9.1", GitCommit:"20adb27c7c5868466912eebdf6664e7390ebe710", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.9.1", GitCommit:"20adb27c7c5868466912eebdf6664e7390ebe710", GitTreeState:"clean"}
```

## 三、设置RBAC （此步骤很重要！）

```bash
# k8s默认开启了RBAC访问控制，所以我们需要为Tiller创建一个ServiceAccount，让他拥有执行的权限，详细内容可以查看 Helm 文档中的Role-based Access Control

$ cat rbac-config.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
 
$ kubectl create -f rbac-config.yaml
 
# 创建了tiller的 ServceAccount 后还没完，因为我们的 Tiller 之前已经就部署成功了，而且是没有指定 ServiceAccount 的，所以我们需要给 Tiller 打上一个 ServiceAccount 的补丁
$ kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
 
# 上面这一步非常重要，不然后面在使用 Helm 的过程中可能出现Error: no available release name found的错误信息
```

```bash
# 更新仓库
$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Skip local chart repository
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈ Happy Helming!⎈

# 至此Helm安装完毕
```

