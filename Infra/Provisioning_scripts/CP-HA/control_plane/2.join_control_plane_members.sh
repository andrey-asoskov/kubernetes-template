#!/usr/bin/env bash

export ETCD_HOST="10.1.1.144"

sudo mkdir -p /etc/kubernetes/pki/etcd/

aws s3 cp --recursive s3://323483035543-k8s-dev/etcd/${ETCD_HOST}/ /tmp/etcd

sudo cp /tmp/etcd/pki/etcd/ca.crt /etc/kubernetes/pki/etcd/
sudo cp /tmp/etcd/pki/apiserver-etcd-client.crt /etc/kubernetes/pki/
sudo cp /tmp/etcd/pki/apiserver-etcd-client.key /etc/kubernetes/pki/


cat << EOF > /tmp/kubeadm-config-control_plane.yaml
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: JoinConfiguration
discovery:
  bootstrapToken:
    token: 1s96st.qw61bt1n6i7b1qww
    apiServerEndpoint: "10.1.2.117:6443"
    caCertHashes: ["sha256:3673ae87c51e620e3492d2ae3226eb862b63b1a0364b919e8d1aff14868b21c6"]
nodeRegistration:
  #name: ip-10-14-18-22.us-west-2.compute.internal
  kubeletExtraArgs:
    cloud-provider: aws
controlPlane:
  #localAPIEndpoint:
    #advertiseAddress: 10.14.18.22
  certificateKey: "6b1d29fd151c4722840af2d918b4491c683702beb4cf192bbedea36e8d517abb"
EOF

cat << EOF > /tmp/kubeadm-config-worker.yaml
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: JoinConfiguration
discovery:
  bootstrapToken:
    token: 1s96st.qw61bt1n6i7b1qww
    apiServerEndpoint: "10.1.2.117:6443"
    caCertHashes: ["sha256:3673ae87c51e620e3492d2ae3226eb862b63b1a0364b919e8d1aff14868b21c6"]
nodeRegistration:
  #name: ip-10-14-18-22.us-west-2.compute.internal
  kubeletExtraArgs:
    cloud-provider: aws
EOF

sudo kubeadm join 10.1.2.117:6443 \
        --config /tmp/kubeadm-config-control_plane.yaml

#Test
export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl get nodes -o wide
kubectl get pods -A

#Upload the config
aws s3 cp /tmp/kubeadm-config-worker.yaml s3://323483035543-k8s-dev/
