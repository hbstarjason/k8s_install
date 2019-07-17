#!/usr/bin/env bash

# https://katacoda.com/courses/kubernetes/launch-single-node-cluster
curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
useradd -m zhang

curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null

bash InstallHalyard.sh --user zhang

hal -v
hal version list

sleep 5
echo "install halyard succeed"

mkdir /root/.kube/ && \
wget https://raw.githubusercontent.com/hbstarjason/k8s_install/master/spinnaker/config

kubectl get node 

sleep 5

hal config provider kubernetes enable
hal config provider kubernetes account add k8s-account \
     --provider-version v2 \
     --context $(kubectl config current-context)

hal config deploy edit --type=distributed --account-name k8s-account

echo "config kubernetes succeed"

hal config storage edit --type redis
hal config features edit --artifacts true

hal config version edit --version 1.12.14

sleep 5

chmod 777 /root/ && chmod 777 /root/.kube/config

cd /home/zhang/.hal/default/ && mkdir service-settings

cat >> clouddriver.yml <<EOF
artifactId: hbstarjason/clouddriver:4.3.10-20190424030608
EOF

cat >> deck.yml <<EOF
artifactId: hbstarjason/deck:2.7.11-20190605125447
overrideBaseUrl: http://deck.spin-daimler.com
EOF

cat >> echo.yml <<EOF
artifactId: hbstarjason/echo:2.3.2-20190701101933
EOF

cat >> front50.yml <<EOF
artifactId: hbstarjason/front50:0.15.2-20190222161456
EOF

cat >> gate.yml <<EOF
artifactId: hbstarjason/gate:1.5.3-20190404174621
overrideBaseUrl: http://gate.spin-daimler.com
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

hal deploy apply

echo "install spinnaker succeed"

hal deploy connect