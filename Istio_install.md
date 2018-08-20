# istio_install

官网地址：https://istio.io/docs/setup/kubernetes/helm-install/

中文：https://istio.io/zh/docs/setup/kubernetes/helm-install/

# 一、Helm安装

```bash
# 官方推荐用helm，不用科学上网。若手动安装，镜像全在gcr.io上，你懂的~~~
# helm安装方法，猛击：https://github.com/hbstarjason/k8s_install/blob/master/install_Helm.md

# 将 Istio 的核心组件呈现为名为 istio.yaml 的 Kubernetes 清单文件
$ helm template install/kubernetes/helm/istio --name istio --namespace istio-system > $HOME/istio.yaml
 
# 通过清单文件安装组件
$ kubectl create namespace istio-system
$ kubectl create -f $HOME/istio.yaml
 
 
# 卸载
$ kubectl delete -f $HOME/istio.yaml
```

# 二、手动安装

```bash
# 安装没什么难的，主要的难度是科学上网下载镜像
# 所需要的镜像
 gcr.io/istio-release/grafana:1.0.0 
 gcr.io/istio-release/citadel:1.0.0 
 quay.io/coreos/hyperkube:v1.7.6_coreos.0 
 gcr.io/istio-release/proxyv2:1.0.0 
 gcr.io/istio-release/mixer:1.0.0 
 gcr.io/istio-release/servicegraph:1.0.0 
 gcr.io/istio-release/galley:1.0.0 
 gcr.io/istio-release/sidecar_injector:1.0.0
 
 # 本人已经将镜像复制了一份上传到dockerhub上了
docker pull hbstarjason/grafana:1.0.0 && \
docker pull hbstarjason/citadel:1.0.0  && \
docker pull hbstarjason/hyperkube:v1.7.6_coreos.0  && \
docker pull hbstarjason/proxyv2:1.0.0  && \
docker pull hbstarjason/mixer:1.0.0  && \
docker pull hbstarjason/servicegraph:1.0.0 && \
docker pull hbstarjason/galley:1.0.0 && \
docker pull hbstarjason/sidecar_injector:1.0.0
 
docker tag hbstarjason/grafana:1.0.0 gcr.io/istio-release/grafana:1.0.0 && \
docker tag hbstarjason/citadel:1.0.0 gcr.io/istio-release/citadel:1.0.0 && \
docker tag hbstarjason/hyperkube:v1.7.6_coreos.0 quay.io/coreos/hyperkube:v1.7.6_coreos.0 && \
docker tag hbstarjason/proxyv2:1.0.0 gcr.io/istio-release/proxyv2:1.0.0  && \
docker tag hbstarjason/mixer:1.0.0 gcr.io/istio-release/mixer:1.0.0 && \
docker tag hbstarjason/servicegraph:1.0.0 gcr.io/istio-release/servicegraph:1.0.0 && \
docker tag hbstarjason/galley:1.0.0 gcr.io/istio-release/galley:1.0.0 && \
docker tag hbstarjason/sidecar_injector:1.0.0 gcr.io/istio-release/sidecar_injector:1.0.0
```



```bash
# 去下面的地址下载压缩包
# https://github.com/istio/istio/releases
$ wget https://github.com/istio/istio/releases/download/1.0.0/istio-1.0.0-linux.tar.gz
$ tar -zvxf istio-1.0.0-linux.tar.gz
 
# 使用官方的安装脚本安装
$ curl -L https://git.io/getLatestIstio | sh -
 
# 安装配置环境变量
$ /root/istio-1.0.0/bin/istioctl version
Version: 1.0.0
GitRevision: 3a136c90ec5e308f236e0d7ebb5c4c5e405217f4
User: root@71a9470ea93c
Hub: gcr.io/istio-release
GolangVersion: go1.10.1
BuildStatus: Clean
 
$ export PATH=/root/istio-1.0.0/bin:$PATH
 
# 安装
$ cd istio-1.0.0/install/kubernetes/
$ vi install/kubernetes/istio-demo.yaml
# type: LoadBalancer,把type改为NodePort
……
spec:
  type: NodePort
  selector:
    app: istio-ingressgateway
    istio: ingressgateway
……
$ kubectl create -f istio-demo.yaml
 
 
# 查看
$ kubectl get svc -n istio-system

$ kubectl get pod -n istio-system
```

