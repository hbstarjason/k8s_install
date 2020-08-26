#!/bin/sh

set -e
mkdir -p tmp
cd tmp
USER=$1
openssl genrsa -out "${USER}.key" 4096
cat > csr.cnf << EOF
[req]
default_bits=2048
prompt=no
default_md=sha256
distinguished_name=dn
[dn]
CN=${USER}
O=dev
[v3_ext]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
EOF

openssl req -config ./csr.cnf -new -key "${USER}.key" -nodes -out "${USER}.csr"

export BASE64_CSR=$(cat ./"${USER}.csr" | base64 | tr -d '\n')

cat > csr.yaml << EOF
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: csr-${USER}
spec:
  groups:
  - system:authenticated
  request: ${BASE64_CSR}
  usages:
  - digital signature
  - key encipherment
  - server auth
  - client auth
EOF

cat csr.yaml | kubectl apply -f -

kubectl certificate approve "csr-${USER}"

kubectl get csr "csr-${USER}" -o jsonpath='{.status.certificate}' \
  | base64 --decode > "${USER}.crt"

openssl x509 -in "./${USER}.crt" -noout -text

CURRENT_CONTEXT=`kubectl config current-context`
CLUSTER_NAME=`kubectl config get-contexts ${CURRENT_CONTEXT} | awk '{print $3}' | tail -n 1`
CLUSTER_ENDPOINT=`kubectl config view -o jsonpath="{.clusters[?(@.name == \"${CLUSTER_NAME}\")].cluster.server}"`
CLUSTER_CA=`kubectl config view --raw -o jsonpath="{.clusters[?(@.name == \"${CLUSTER_NAME}\")].cluster.certificate-authority-data}"`
CLIENT_CERTIFICATE_DATA=$(kubectl get csr "csr-${USER}" -o jsonpath='{.status.certificate}')
CLIENT_KEY_DATA=`cat ${USER}.key | base64 | tr -d '\n' `

cat > "kubeconfig-${USER}" << EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${CLUSTER_CA}
    server: ${CLUSTER_ENDPOINT}
  name: ${CLUSTER_NAME}
users:
- name: ${USER}
  user:
    client-certificate-data: ${CLIENT_CERTIFICATE_DATA}
    client-key-data: ${CLIENT_KEY_DATA}
contexts:
- context:
    cluster: ${CLUSTER_NAME}
    user: ${USER}
  name: ${USER}-${CLUSTER_NAME}
current-context: ${USER}-${CLUSTER_NAME}
EOF

cp "kubeconfig-${USER}" ..
cd ..
rm -Rf tmp

echo "Now you can try: kubectl get nodes --kubeconfig=kubeconfig-${USER}"