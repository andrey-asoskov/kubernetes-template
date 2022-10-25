#!/usr/bin/env bash

#kube-prometheus setup
minikube delete && minikube start --kubernetes-version=v1.25.0 \
--memory=6g --bootstrapper=kubeadm \
--driver=virtualbox \
--extra-config=kubelet.authentication-token-webhook=true \
--extra-config=kubelet.authorization-mode=Webhook \
--extra-config=scheduler.bind-address=0.0.0.0 \
--extra-config=controller-manager.bind-address=0.0.0.0

kubectl get pods -A

minikube pause
minikube unpause
