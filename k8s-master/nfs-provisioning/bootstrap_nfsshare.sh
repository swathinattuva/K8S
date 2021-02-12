# Disable SELinux
echo "[TASK 1] Disable SELinux"
setenforce 0
sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

# Add sysctl settings
echo "[TASK 2] Add sysctl settings"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system >/dev/null 2>&1

# Disable swap
echo "[TASK 3] Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a


echo "[TASK 4] Install NFS"
yum install nfs-utils -y

echo "[TASK 5] Create share folder and Assign Appropriate Permissions"
mkdir -p /opt/nfs_share
chmod -R 755 /opt/nfs_share
chown nfsnobody:nfsnobody /opt/nfs_share


echo "[TASK 6] Start NFS servers"
systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap

echo "[TASK 7] Create NFS config file"
cat >>/etc/exports<<EOF
/opt/nfs_share *(rw,sync,no_subtree_check,no_root_squash,no_all_squash,insecure)
EOF

echo "[TASK 8] Restart NFS server"
systemctl restart nfs-server

# Update hosts file
echo "[TASK 9] Update /etc/hosts file"
cat >>/etc/hosts<<EOF
172.42.42.100 kmaster.example.com kmaster
172.42.42.101 kworker1.example.com kworker1
172.42.42.102 kworker2.example.com kworker2
172.42.42.103 kworker3.exmaple.com kworker3
172.42.42.150 nfsshare.example.com nfsshare
EOF
