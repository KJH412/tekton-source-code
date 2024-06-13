nmcli con sh
nmtui edit "Wired connection 1"
nmtui
nmcli con up eth1
ip a s eth1
ip link
hostnamectl set-hostname aio.example.com
hostname
cat <<EOF>> /etc/hosts
192.168.10.10  aio.example.com
EOF

ping -c3 aio.example.com
cat <<EOF> /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.26/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.26/rpm/repodata/repomd.xml.key
EOF

dnf repolist
nano /etc/selinux/config
setenforce 0
getenforce
systemctl disable --now firewalld
nano /etc/fstab
systemctl daemon-reload
swapoff -a
swapon -s
cat <<EOF | tee /etc/yum.repos.d/cri-o.repo
[cri-o]
name=CRI-O
baseurl=https://pkgs.k8s.io/addons:/cri-o:/prerelease:/main/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/addons:/cri-o:/prerelease:/main/rpm/repodata/repomd.xml.key
EOF

dnf install -y conntrack container-selinux ebtables ethtool iptables socat
dnf install -y kubeadm kubectl kubelet cri-o -y
systemctl enable --now crio
systemctl enable --now kubelet
modprobe br_netfilter
modprobe overlay
cat <<EOF> /etc/modules-load.d/k8s-modules.conf
br_netfilter
overlay
EOF

cat <<EOF> /etc/sysctl.d/k8s-mod.conf
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-ip6tables=1
EOF

sysctl --system
dracut -f
exit
