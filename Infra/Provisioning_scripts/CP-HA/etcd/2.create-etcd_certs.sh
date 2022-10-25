#!/usr/bin/env bash


#Generate the certificate authority
sudo kubeadm init phase certs etcd-ca

export HOST0=10.1.1.144
export HOST1=10.1.2.242
export HOST2=10.1.3.221

export prefix='/tmp/etcd'

#Cleanup
sudo find /etc/kubernetes/pki -not -name ca.crt -not -name ca.key -type f -delete

#Create certificates for each member
sudo kubeadm init phase certs etcd-server --config=${prefix}/${HOST2}/kubeadmcfg.yaml
sudo kubeadm init phase certs etcd-peer --config=${prefix}/${HOST2}/kubeadmcfg.yaml
sudo kubeadm init phase certs etcd-healthcheck-client --config=${prefix}/${HOST2}/kubeadmcfg.yaml
sudo kubeadm init phase certs apiserver-etcd-client --config=${prefix}/${HOST2}/kubeadmcfg.yaml
sudo cp -R /etc/kubernetes/pki ${prefix}/${HOST2}/
# cleanup non-reusable certificates
sudo find /etc/kubernetes/pki -not -name ca.crt -not -name ca.key -type f -delete

sudo kubeadm init phase certs etcd-server --config=${prefix}/${HOST1}/kubeadmcfg.yaml
sudo kubeadm init phase certs etcd-peer --config=${prefix}/${HOST1}/kubeadmcfg.yaml
sudo kubeadm init phase certs etcd-healthcheck-client --config=${prefix}/${HOST1}/kubeadmcfg.yaml
sudo kubeadm init phase certs apiserver-etcd-client --config=${prefix}/${HOST1}/kubeadmcfg.yaml
sudo cp -R /etc/kubernetes/pki ${prefix}/${HOST1}/
sudo find /etc/kubernetes/pki -not -name ca.crt -not -name ca.key -type f -delete

sudo kubeadm init phase certs etcd-server --config=${prefix}/${HOST0}/kubeadmcfg.yaml
sudo kubeadm init phase certs etcd-peer --config=${prefix}/${HOST0}/kubeadmcfg.yaml
sudo kubeadm init phase certs etcd-healthcheck-client --config=${prefix}/${HOST0}/kubeadmcfg.yaml
sudo kubeadm init phase certs apiserver-etcd-client --config=${prefix}/${HOST0}/kubeadmcfg.yaml
sudo cp -R /etc/kubernetes/pki ${prefix}/${HOST0}/
sudo find /etc/kubernetes/pki -not -name ca.crt -not -name ca.key -type f -delete

#Upload the config
aws s3 cp --recursive ${prefix}/ s3://323483035543-k8s-dev/etcd/
