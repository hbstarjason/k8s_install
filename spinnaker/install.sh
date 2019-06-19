# wget https://raw.githubusercontent.com/hbstarjason/k8s_install/master/spinnaker/install.sh

kubectl apply -f  https://raw.githubusercontent.com/hbstarjason/k8s_install/master/spinnaker/minio-pv.yml
kubectl apply -f  https://raw.githubusercontent.com/hbstarjason/k8s_install/master/spinnaker/quick-install-spinnaker.yml

# official
# kubectl apply -f https://spinnaker.io/downloads/kubernetes/quick-install.yml


