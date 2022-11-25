#!/usr/bin/env bash

#Single node
minikube start \
--driver=hyperkit \
--kubernetes-version=v1.25.0 \
--container-runtime=containerd \
--bootstrapper=kubeadm \
--memory=6g \
--cpus='2' \
--cni calico \
--extra-config=kubelet.authentication-token-webhook=true \
--extra-config=kubelet.authorization-mode=Webhook \
--extra-config=scheduler.bind-address=0.0.0.0 \
--extra-config=controller-manager.bind-address=0.0.0.0

#HA
minikube start \
--driver=hyperkit \
--kubernetes-version=v1.25.0 \
--container-runtime=containerd \
--bootstrapper=kubeadm \
--memory=4g \
--cpus='1' \
--nodes=3 \
--cni calico \
--extra-config=kubelet.authentication-token-webhook=true \
--extra-config=kubelet.authorization-mode=Webhook \
--extra-config=scheduler.bind-address=0.0.0.0 \
--extra-config=controller-manager.bind-address=0.0.0.0

minikube delete 
