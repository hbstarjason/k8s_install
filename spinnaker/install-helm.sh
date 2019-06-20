# from https://blog.ik.am/entries/473

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EOF

helm init --service-account tiller
helm upate

kubectl create ns spinnaker

cat <<EOF >> values.yml
accounts:
- address: https://index.docker.io
  name: dockerhub
  repositories:
  - making/hello-pks
dockerRegistries:
- name: dockerhub
  address: index.docker.io
  repositories:
    - making/hello-pks
EOF

helm install --name spinnaker stable/spinnaker --timeout 6000 --debug --namespace spinnaker -f values.yml

helm list

kubectl patch -n spinnaker service spin-deck --type='json' -p='[{"op": "replace", "path": "/spec/type", "value": "LoadBalancer" }]'
kubectl patch -n spinnaker service spin-gate --type='json' -p='[{"op": "replace", "path": "/spec/type", "value": "LoadBalancer" }]'

