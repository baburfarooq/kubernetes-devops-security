#!/bin/bash

set -e

echo ".........----------------#################._.-.-INSTALL-.-._.#################----------------........."

# Update PS1 for the current session and append to .bashrc
PS1='\[\e[01;36m\]\u\[\e[01;37m\]@\[\e[01;33m\]\H\[\e[01;37m\]:\[\e[01;32m\]\w\[\e[01;37m\]\$\[\033[0;37m\] '
echo "PS1='\[\e[01;36m\]\u\[\e[01;37m\]@\[\e[01;33m\]\H\[\e[01;37m\]:\[\e[01;32m\]\w\[\e[01;37m\]\$\[\033[0;37m\] '" >> ~/.bashrc
echo 'force_color_prompt=yes' >> ~/.bashrc
source ~/.bashrc

# System updates and cleanup
sudo apt-get update
sudo apt-get autoremove -y

# Add Kubernetes APT repository
sudo rm -f /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-$(lsb_release -c | awk '{print $2}') main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Add Jenkins repository
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo gpg --dearmor -o /usr/share/keyrings/jenkins-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/jenkins-archive-keyring.gpg] http://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list

# Install required packages
sudo apt-get update
sudo apt-get install -y docker.io vim build-essential jq python3-pip kubelet kubectl kubeadm
pip3 install jc

# Verify Kubernetes installation
dpkg -l | grep -E 'kubelet|kubectl|kubeadm'

# Docker configuration
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "storage-driver": "overlay2"
}
EOF
sudo systemctl restart docker || true
sudo systemctl enable docker || true

# Initialize Kubernetes
rm -f ~/.kube/config || true
sudo kubeadm reset -f || true
sudo kubeadm init --skip-token-print

mkdir -p ~/.kube
sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config

# Apply Weave Network
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

sleep 60

# Untaint control plane node
kubectl taint node $(kubectl get nodes -o=jsonpath='{.items[].metadata.name}') node.kubernetes.io/not-ready:NoSchedule- || true
kubectl taint node $(kubectl get nodes -o=jsonpath='{.items[].metadata.name}') node-role.kubernetes.io/master:NoSchedule- || true
kubectl get nodes -o wide

echo ".........----------------#################._.-.-Java and MAVEN-.-._.#################----------------........."
sudo apt-get install -y openjdk-11-jdk maven
java -version
mvn -v

echo ".........----------------#################._.-.-JENKINS-.-._.#################----------------........."
# Ensure Jenkins repository GPG key is correctly added
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo gpg --dearmor -o /usr/share/keyrings/jenkins-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/jenkins-archive-keyring.gpg] http://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list

# Update and install Jenkins
sudo apt-get update
sudo apt-get install -y jenkins
sudo systemctl daemon-reload || true
sudo systemctl enable jenkins || true
sudo systemctl start jenkins || true

# Add Jenkins to docker group and grant passwordless sudo access
sudo usermod -aG docker jenkins || true
echo "jenkins ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers

echo ".........----------------#################._.-.-COMPLETED-.-._.#################----------------........."
