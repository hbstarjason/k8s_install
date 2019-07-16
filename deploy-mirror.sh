#!/bin/bash

### Docker Engine
# http://mirror.azure.cn/help/docker-engine.html
curl -skSL https://mirror.azure.cn/repo/install-docker-ce.sh | sh -s -- --mirror AzureChinaCloud

### kubectl
# http://mirror.azure.cn/help/kubernetes.html
KUBECTL_VER=v1.15.0
wget https://mirror.azure.cn/kubernetes/kubectl/$KUBECTL_VER/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

### Helm
# http://mirror.azure.cn/help/kubernetes.html
HELM_VER=v2.14.0
wget https://mirror.azure.cn/kubernetes/helm/helm-$HELM_VER-linux-amd64.tar.gz
tar -xvf helm-$HELM_VER-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin 
helm init --tiller-image gcr.azk8s.cn/kubernetes-helm/tiller:$HELM_VER --stable-repo-url https://mirror.azure.cn/kubernetes/charts/ 

helm repo add stable http://mirror.azure.cn/kubernetes/charts/
helm repo add incubator http://mirror.azure.cn/kubernetes/charts-incubator/

### GCR Proxy Cache
# http://mirror.azure.cn/help/gcr-proxy-cache.html
# docker pull gcr.azk8s.cn/google_containers/pause-amd64:3.0
# docker pull gcr.azk8s.cn/google_containers/kubedns-amd64:1.7