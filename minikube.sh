# https://gist.github.com/kevin-smets/b91a34cea662d0c523968472a81788f7

brew update && brew install kubectl && brew cask install docker minikube virtualbox

minikube dashboard
minikube addons enable ingress

minikube ip
minikube ssh
minikube dashboard
minikube service list


docker run -d -p 5000:5000 --restart=always --name registry registry:2

brew install kubernetes-helm
helm init
kubectl describe deploy tiller-deploy — namespace=kube-system


kubectl run hello-minikube --image=k8s.gcr.io/echoserver:1.10 --port=8080
kubectl get pods
kubectl expose deployment hello-minikube --type=NodePort
kubectl get services
curl $(minikube service hello-minikube --url)
eval $(minikube docker-env)
docker ps
kubectl delete services hello-minikube
kubectl delete deployment hello-minikube



############### https://yq.aliyun.com/articles/221687

# 
curl -Lo minikube http://kubernetes.oss-cn-hangzhou.aliyuncs.com/minikube/releases/v1.1.1/minikube-darwin-amd64 \
&& chmod +x minikube && sudo mv minikube /usr/local/bin/

# 
minikube start --registry-mirror=https://registry.docker-cn.com --kubernetes-version v1.14.1

minikube start --vm-driver=none
minikube start --vm-driver hyperkit
minikube start --vm-driver hyperv

brew install kubernetes-helm
helm init --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.14.1 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts

minikube addons enable ingress

kubectl run nginx --replicas=2 --image=nginx:alpine --port=80 --image-pull-policy=IfNotPresent
kubectl expose deployment nginx --type=NodePort --name=example-service-nodeport

# ClusterIP
kubectl expose deployment nginx --name=example-service

minikube logs

minikube config set memory 8192
minikube config set cpus 4

# https://qii404.me/2018/01/06/minukube.html

# https://kubernetes.feisky.xyz/cha-jian-kuo-zhan/ingress/minikube-ingress

docker pull quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.23.0 && \
docker tag quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.23.0 hbstarjason/nginx-ingress-controller:0.23.0 && \
docker push hbstarjason/nginx-ingress-controller:0.23.0

docker pull hbstarjason/nginx-ingress-controller:0.23.0 && \
docker tag hbstarjason/nginx-ingress-controller:0.23.0 quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.23.0 && \
docker rmi hbstarjason/nginx-ingress-controller:0.23.0 
