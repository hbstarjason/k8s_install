
# https://www.katacoda.com/courses/kubernetes/helm-package-manager
# wget https://raw.githubusercontent.com/hbstarjason/k8s_install/master/deploy-nfs.sh

LOCAL_IP=$(ifconfig ens3 |grep "inet addr"| cut -f 2 -d ":"|cut -f 1 -d " ")

mkdir -p /data/nfs && chmod a+rw /data/nfs

apt-get update && apt-get install -y nfs-kernel-server nfs-common

cat << EOF >> /etc/exports
/data/nfs *(rw,sync,insecure,no_subtree_check,no_root_squash)
EOF

exportfs -r
/etc/init.d/nfs-kernel-server restart

showmount -e localhost

mkdir -p /data/nfs-mount
mount ${LOCAL_IP}:/data/nfs  /data/nfs-mount
df -h

# umount /data/nfs-mount
ip addr > /data/nfs-mount/test.txt
cat /data/nfs/test.txt

# install NFS-Client Provisioner 
helm install -n nfs stable/nfs-client-provisioner --set nfs.server=${LOCAL_IP} --set nfs.path=/data/nfs --namespace nfs
