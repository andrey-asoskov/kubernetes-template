#!/usr/bin/env bash

export KUBECONFIG=/etc/kubernetes/admin.conf

#Install Calico operator
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/tigera-operator.yaml

#Make sure pod CIDR doesn't overlap and deploy Calico config
wget https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/custom-resources.yaml
kubectl create -f ./custom-resources.yaml

#Wait for all pods running and ready
watch kubectl get pods -A
