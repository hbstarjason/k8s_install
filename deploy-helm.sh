#!/bin/bash

# wget https://raw.githubusercontent.com/hbstarjason/k8s_install/master/deploy-helm.sh 

# curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash

HELM_VERSION="v2.14.0"

curl -sSL https://kubernetes-helm.storage.googleapis.com/helm-${HELM_VERSION}-linux-amd64.tar.gz -o helm-linux-amd64.tar.gz

# wget -c https://kubernetes-helm.storage.googleapis.com/helm-v2.14.0-linux-amd64.tar.gz

tar zxvf helm-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/
rm -rf helm-linux-amd64.tar.gz linux-amd64

# init helm
kubectl create -f https://raw.githubusercontent.com/hbstarjason/k8s_install/master/helm-admin-rbac.yaml 
helm init

# helm init --service-account tiller --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.14.0 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts

# update repo
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
helm repo update

