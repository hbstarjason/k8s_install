
# wget https://raw.githubusercontent.com/hbstarjason/k8s_install/master/deploy-nfs.sh

mkdir -p /data/nfs && chmod a+rw /data/nfs

apt-get update && apt-get install -y nfs-kernel-server nfs-common

cat << EOF >> /etc/exports
/data/nfs *(rw,sync,no_subtree_check)
EOF

/etc/init.d/nfs-kernel-server restart

mkdir -p /data/nfs-mount
mount 172.17.0.17:/data/nfs  /data/nfs-mount
df

# umount /data/nfs-mount
# ip addr > /data/nfs-mount/test.txt
# cat /data/nfs/test.txt
