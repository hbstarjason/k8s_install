```bash
#方法一
$ wget https://get.helm.sh/helm-v3.2.4-linux-amd64.tar.gz
$ tar -zxvf helm-v3.2.4-linux-amd64.tar.gz
$ mv linux-amd64/helm /usr/local/bin/helm
$ helm repo add stable http://mirror.azure.cn/kubernetes/charts
$ helm version

# HELMVERSION=helm-v3.2.4
# curl -sSL https://get.helm.sh/${HELMVERSION}-linux-amd64.tar.gz | \
    sudo tar xz -C /usr/local/bin --strip-components=1 linux-amd64/helm
```

```bash
# 方法二
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
chmod 700 get_helm.sh && \
 ./get_helm.sh && helm repo add stable http://mirror.azure.cn/kubernetes/charts

$ helm version 
```

