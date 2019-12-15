
# https://katacoda.com/courses/kubernetes/launch-single-node-cluster
curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
useradd -m zhang

curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null

bash InstallHalyard.sh --user zhang

hal -v
hal version list

################################################

curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker zhang
sudo docker run -p 127.0.0.1:9090:9000 -d --name minio1 -v /mnt/data:/data -v /mnt/config:/root/.minio minio/minio server /data

sudo apt-get -y install jq

MINIO_SECRET_KEY=`echo $(sudo docker exec minio1 cat /root/.minio/config.json) |jq -r '.credential.secretKey'`
MINIO_ACCESS_KEY=`echo $(sudo docker exec minio1 cat /root/.minio/config.json) |jq -r '.credential.accessKey'`
echo $MINIO_SECRET_KEY | hal config storage s3 edit --endpoint http://127.0.0.1:9090 \
    --access-key-id $MINIO_ACCESS_KEY \
    --secret-access-key

hal config storage edit --type s3

############################################################
read version
if [ -z "$version" ]
then
	echo ""
else
	echo $version>version.tmp
	break
fi
done
hal config version edit --version `cat version.tmp`
# hal config version edit --version $VERSION


SPINNAKER_VERSION=XXXX
set -e

if [ -z "${SPINNAKER_VERSION}" ] ; then
  echo "SPINNAKER_VERSION not set"
  exit
fi
sudo hal config version edit --version $SPINNAKER_VERSION
###############################################################


sleep 5
echo "install halyard succeed"

mkdir /root/.kube/ && cd /root/.kube/
# wget https://raw.githubusercontent.com/hbstarjason/k8s_install/master/spinnaker/config

kubectl get node 

## config kubernetes
hal config provider kubernetes enable
hal config provider kubernetes account add k8s-account \
     --provider-version v2 \
     --context $(kubectl config current-context)

hal config deploy edit --type=distributed --account-name k8s-account

# add k8s cluster
hal config provider kubernetes account add k8s-test --provider-version v2  --kubeconfig-file /root/.kube/XXX


echo "config kubernetes succeed"

hal config storage edit --type redis
hal config features edit --artifacts true

hal config version edit --version 1.12.14

chmod 777 /root/ && chmod 777 /root/.kube/config

cd /home/zhang/.hal/default/ && \
mkdir service-settings && \
cd service-settings


cat >> clouddriver.yml <<EOF
artifactId: hbstarjason/clouddriver:4.3.10-20190424030608
EOF

cat >> deck.yml <<EOF
artifactId: hbstarjason/deck:2.7.11-20190605125447
overrideBaseUrl: http://deck.spin-dml.local
EOF

cat >> echo.yml <<EOF
artifactId: hbstarjason/echo:2.3.2-20190701101933
EOF

cat >> front50.yml <<EOF
artifactId: hbstarjason/front50:0.15.2-20190222161456
EOF

cat >> gate.yml <<EOF
artifactId: hbstarjason/gate:1.5.3-20190404174621
overrideBaseUrl: http://gate.spin-dml.local
EOF

cat >> orca.yml <<EOF
artifactId: hbstarjason/orca:2.4.3-20190619172946
EOF

cat >> redis.yml <<EOF
artifactId: hbstarjason/redis-cluster:v2
EOF

cat >> rosco.yml <<EOF
artifactId: hbstarjason/rosco:0.10.0-20190315030608
EOF

# hal config security ui edit --override-base-url http://deck.spin-dml.local
# hal config security api edit --override-base-url http://gate.spin-dml.local

hal deploy apply

# hal deploy connect



# tar -zcvf hal-config.tar.gz /home/zhang/.hal
# tar -zxvf hal-config.tar.gz

# hal backup create
# hal backup restore --backup-path <backup-name>.tar


cat >> spin-ingress.yml <<EOF
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: spinnaker
  namespace: spinnaker
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: deck.spin-dml.local
    http:
     paths:
     - path: /
       backend:
          serviceName: spin-deck
          servicePort: 9000
  - host: gate.spin-dml.local
    http:
     paths:
      - path: /
        backend:
          serviceName: spin-gate
          servicePort: 8084
EOF

kubectl apply -f spin-ingress.yml -n spinnaker


helm install stable/nginx-ingress --namespace ingress-basic --set controller.replicaCount=1 --set defaultBackend.image.repository=gcr.azk8s.cn/google_containers/defaultbackend
gcr.azk8s.cn/google_containers/defaultbackend-amd64:1.5



####################

# kubectl create ns nginx
apiVersion: v1
kind: Namespace
metadata:
  name: nginx

# kubectl run nginx --replicas=2 --image=nginx:alpine --port=80 --dry-run -o yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: nginx
  labels:
    run: nginx
  name: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      run: nginx
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        run: nginx
    spec:
      containers:
      - image: nginx:alpine
        name: nginx
        ports:
        - containerPort: 80
        resources: {}
status: {}


# kubectl expose -n nginx deployment nginx --type=LoadBalancer --name=nginx-lb --dry-run -o yaml 
apiVersion: v1
kind: Service
metadata:
  namespace: nginx
  labels:
    app.kubernetes.io/managed-by: spinnaker
    app.kubernetes.io/name: nginxtest
    run: nginx
  name: nginx-lb
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    run: nginx
  type: LoadBalancer
status:
  loadBalancer: {}

