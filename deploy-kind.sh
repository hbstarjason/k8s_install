# install kubectl 
sudo snap install kubectl --classic
kubectl version

# curl -Lo ./kind-linux-amd64 https://github.com/kubernetes-sigs/kind/releases/download/v0.3.0/kind-linux-amd64 && \
# chmod +x ./kind-linux-amd64 && \
# mv ./kind-linux-amd64 /usr/local/bin/kind && \
curl -L https://github.com/kubernetes-sigs/kind/releases/download/v0.3.0/kind-`uname -s`-`uname -m` > /usr/local/bin/kind && \
chmod +x /usr/local/bin/kind
kind version

cat <<EOF >  kind-config.yaml
# https://kind.sigs.k8s.io/docs/user/quick-start/
# three node (two workers) cluster config
kind: Cluster
apiVersion: kind.sigs.k8s.io/v1alpha3
nodes:
- role: control-plane
- role: worker
- role: worker
EOF

kind create cluster --config=kind-config.yaml

export KUBECONFIG="$(kind get kubeconfig-path --name="kind")"

# install helm 
sudo snap install helm --classic
helm version
helm init
