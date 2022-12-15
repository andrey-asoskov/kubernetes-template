#!/usr/bin/env bash

sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

#sudo apt-get install -y kubelet kubeadm kubectl
export K8S_VER="1.25.4-00"
sudo apt-get install -y kubelet=${K8S_VER} kubeadm=${K8S_VER} kubectl=${K8S_VER}

sudo apt-mark hold kubelet kubeadm kubectl
