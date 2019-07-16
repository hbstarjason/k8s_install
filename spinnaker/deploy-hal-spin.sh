
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

hal config storage edit --type redis

hal config provider kubernetes enable
hal config provider kubernetes account add k8s-account \
     --provider-version v2 \
     --context $(kubectl config current-context)

hal config deploy edit --type=distributed --account-name k8s-account

hal config version edit --version 1.12.14
hal version bom 1.12.14

chmod 777 /root/ && chmod 777 /root/.kube/config
hal deploy apply
hal deploy connect


