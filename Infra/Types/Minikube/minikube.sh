#!/usr/bin/env bash

#Single node
minikube start \
--driver=hyperkit \
--kubernetes-version=v1.25.4 \
--container-runtime=containerd \
--bootstrapper=kubeadm \
--memory=6g \
--cpus='2' \
--cni calico \
--extra-config=kubelet.authentication-token-webhook=true \
--extra-config=kubelet.authorization-mode=Webhook \
--extra-config=scheduler.bind-address=0.0.0.0 \
--extra-config=controller-manager.bind-address=0.0.0.0

minikube start \
--kubernetes-version=v1.25.4 \
--cni calico

#HA
minikube start \
--driver=hyperkit \
--kubernetes-version=v1.25.4 \
--container-runtime=containerd \
--bootstrapper=kubeadm \
--memory=4g \
--cpus='2' \
--nodes=2 \
--cni calico \
--extra-config=kubelet.authentication-token-webhook=true \
--extra-config=kubelet.authorization-mode=Webhook \
--extra-config=scheduler.bind-address=0.0.0.0 \
--extra-config=controller-manager.bind-address=0.0.0.0

minikube delete 
