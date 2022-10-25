#!/usr/bin/env bash

export ETCD_HOST="10.1.1.144"

sudo mkdir -p /etc/kubernetes/pki/etcd/

aws s3 cp --recursive s3://323483035543-k8s-dev/etcd/${ETCD_HOST}/ /tmp/etcd

sudo cp /tmp/etcd/pki/etcd/ca.crt /etc/kubernetes/pki/etcd/
sudo cp /tmp/etcd/pki/apiserver-etcd-client.crt /etc/kubernetes/pki/
sudo cp /tmp/etcd/pki/apiserver-etcd-client.key /etc/kubernetes/pki/


cat << EOF > /tmp/kubeadm-config.yaml
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
#kubernetesVersion: stable
kubernetesVersion: "1.24.5"
controlPlaneEndpoint: "10.1.2.117:6443" # change this (see below)
networking:
  podSubnet: "192.168.0.0/16"
etcd:
  external:
    endpoints:
      - https://10.1.1.144:2379 # change ETCD_0_IP appropriately
      - https://10.1.2.242:2379 # change ETCD_1_IP appropriately
      - https://10.1.3.221:2379 # change ETCD_2_IP appropriately
    caFile: /etc/kubernetes/pki/etcd/ca.crt
    certFile: /etc/kubernetes/pki/apiserver-etcd-client.crt
    keyFile: /etc/kubernetes/pki/apiserver-etcd-client.key
apiServer:
  extraArgs:
    cloud-provider: aws
controllerManager:
  extraArgs:
    cloud-provider: aws
scheduler:
  extraArgs:
---    
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
nodeRegistration:
  kubeletExtraArgs:
    cloud-provider: aws
EOF

sudo kubeadm init --config /tmp/kubeadm-config.yaml --upload-certs

#Test
export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl get nodes -o wide
kubectl get pods -A

#Get join command for workers
#kubeadm token create --print-join-command

#Upload the config
aws s3 cp /etc/kubernetes/admin.conf s3://323483035543-k8s-dev/
