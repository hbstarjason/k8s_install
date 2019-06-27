###### https://www.spinnaker.io/setup/install/halyard/
curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
sudo bash InstallHalyard.sh
hal -v
sudo update-halyard

mkdir ~/.hal
docker run -p 8084:8084 -p 9000:9000 \
    --name halyard --rm \
    -v ~/.hal:/home/spinnaker/.hal \
    -d \
    gcr.io/spinnaker-marketplace/halyard:stable


###### https://github.com/aws-samples/aws-deploy-spinnaker-halyard/blob/master/scripts/start_hal_daemon.sh
docker run -p 8084:8084 -p 9000:9000 \
    --name halyard --rm \
    -v $(pwd)/.hal:/home/spinnaker/.hal \
    -v ~/.kube:/home/spinnaker/.kube \
    -v ~/.aws:/home/spinnaker/.aws \
    -d \
    gcr.io/spinnaker-marketplace/halyard:stable

docker exec -it halyard bash
source <(hal --print-bash-completion)

###### https://blogs.oracle.com/developers/install-spinnaker-with-halyard-on-kubernetes
mkdir halyard && chmod 747 halyard
mkdir k8s && cp $KUBECONFIG k8s/config && chmod 755 k8s/config

docker run -p 8084:8084 -p 9000:9000 \
    --name halyard -d \
    -v /sandbox/halyard:/home/spinnaker/.hal \
    -v /sandbox/k8s:/home/spinnaker/k8s \
    -e http_proxy=http://<proxy_host>:<proxy_port> \
    -e https_proxy=https://<proxy_host>:<proxy_port> \    
    -e JAVA_OPTS="-Dhttps.proxyHost=<proxy_host> -Dhttps.proxyPort=<proxy_port>" \
    -e KUBECONFIG=/home/spinnaker/k8s/config \
    gcr.io/spinnaker-marketplace/halyard:stable

docker exec -it halyard bash
kubectl get pods -n spinnaker


###### wget https://raw.githubusercontent.com/hbstarjason/k8s_install/master/spinnaker/install.sh

kubectl apply -f  https://raw.githubusercontent.com/hbstarjason/k8s_install/master/spinnaker/minio-pv.yml
kubectl apply -f  https://raw.githubusercontent.com/hbstarjason/k8s_install/master/spinnaker/quick-install-spinnaker.yml

# official
# kubectl apply -f https://spinnaker.io/downloads/kubernetes/quick-install.yml
# https://github.com/spinnaker/spinnaker.github.io/blob/master/downloads/kubernetes/quick-install.yml

# wget https://spinnaker.io/downloads/kubernetes/quick-install.yml
# sed -i "s/standard/nfs-client/g" quick-install.yml
# kubectl apply -f quick-install.yml


cat <<EOF >> spinnaker-minio-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: spinnaker-minio
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: standard
EOF
 
kubectl apply -f spinnaker-minio-pvc.yaml

cat <<EOF >> spinnaker-redis-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  labels:
    app: spinnaker-redis
    chart: redis-1.1.6
    heritage: Tiller
    release: spinnaker
  name: redis-data-spinnaker-redis-master-0
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 8Gi
  storageClassName: standard
EOF

kubectl apply -f spinnaker-redis-pvc.yaml

helm install --name spinnaker stable/spinnaker --debug 
