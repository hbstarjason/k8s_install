# yum install -y wget 
# https://raw.githubusercontent.com/hbstarjason/k8s_install/master/deploy-pwk.sh && sh deploy-pwk.sh

kubeadm init --apiserver-advertise-address $(hostname -i)

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -n kube-system -f \
    "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 |tr -d '\n')"
    
# install dashboard
curl -L -s https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml  | sed 's/targetPort: 9090/targetPort: 9090\n  type: LoadBalancer/' | kubectl apply -f -

# install helm
wget https://raw.githubusercontent.com/hbstarjason/k8s_install/master/deploy-helm.sh  && sh deploy-helm.sh
