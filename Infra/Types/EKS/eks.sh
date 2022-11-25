#!/usr/bin/env bash

AWS_PROFILE=flashslash eksctl create cluster --config-file=Single.yaml --dry-run
AWS_PROFILE=flashslash eksctl create cluster --config-file=Single.yaml

#Delete 
AWS_PROFILE=flashslash eksctl delete cluster --name test-eks \
--disable-nodegroup-eviction --force
