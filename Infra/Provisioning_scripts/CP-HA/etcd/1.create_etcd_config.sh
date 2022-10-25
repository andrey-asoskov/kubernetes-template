#!/usr/bin/env bash

# Update HOST0, HOST1 and HOST2 with the IPs of your hosts
export HOST0=10.1.1.144
export HOST1=10.1.2.242
export HOST2=10.1.3.221

# Update NAME0, NAME1 and NAME2 with the hostnames of your hosts
export NAME0="ip-10-1-1-144"
export NAME1="ip-10-1-2-242"
export NAME2="ip-10-1-3-221"

# Create temp directories to store files that will end up on other hosts.
rm -rf /tmp/etcd
mkdir -p /tmp/etcd/${HOST0}/ /tmp/etcd/${HOST1}/ /tmp/etcd/${HOST2}/

HOSTS=(${HOST0} ${HOST1} ${HOST2})
NAMES=(${NAME0} ${NAME1} ${NAME2})

for i in "${!HOSTS[@]}"; do
HOST=${HOSTS[$i]}
NAME=${NAMES[$i]}
cat << EOF > /tmp/etcd/${HOST}/kubeadmcfg.yaml
---
apiVersion: "kubeadm.k8s.io/v1beta3"
kind: InitConfiguration
nodeRegistration:
    name: ${NAME}
localAPIEndpoint:
    advertiseAddress: ${HOST}
---
apiVersion: "kubeadm.k8s.io/v1beta3"
kind: ClusterConfiguration
kubernetesVersion: "1.24.5"
etcd:
    local:
        serverCertSANs:
        - "${HOST}"
        peerCertSANs:
        - "${HOST}"
        extraArgs:
            initial-cluster: ${NAMES[0]}=https://${HOSTS[0]}:2380,${NAMES[1]}=https://${HOSTS[1]}:2380,${NAMES[2]}=https://${HOSTS[2]}:2380
            initial-cluster-state: new
            name: ${NAME}
            listen-peer-urls: https://${HOST}:2380
            listen-client-urls: https://${HOST}:2379
            advertise-client-urls: https://${HOST}:2379
            initial-advertise-peer-urls: https://${HOST}:2380
EOF
done

aws s3 rm --recursive s3://323483035543-k8s-dev/etcd/
aws s3 cp --recursive /tmp/etcd/ s3://323483035543-k8s-dev/etcd/
