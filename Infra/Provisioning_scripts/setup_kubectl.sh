#!/usr/bin/env bash

echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' >> ~/.bashrc

apt-get install bash-completion vim -y

echo "source <(kubectl completion bash)" >> $HOME/.bashrc
echo 'alias kc=kubectl' >> ~/.bashrc
echo 'complete -F __start_kubectl kc'  >> ~/.bashrc

source ~/.bashrc
