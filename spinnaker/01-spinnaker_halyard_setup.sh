# https://katacoda.com/courses/kubernetes/launch-single-node-cluster
# wget https://raw.githubusercontent.com/hbstarjason/k8s_install/master/spinnaker/01-spinnaker_halyard_setup.sh && sh 01-spinnaker_halyard_setup.sh

SPINNAKER_VERSION=1.14.15

curl -O https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
useradd -m zhang

curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null

bash InstallHalyard.sh --user zhang -y

set -e

if [ -z "${SPINNAKER_VERSION}" ] ; then
  echo "SPINNAKER_VERSION not set"
  exit
fi

sudo hal config version edit --version $SPINNAKER_VERSION
