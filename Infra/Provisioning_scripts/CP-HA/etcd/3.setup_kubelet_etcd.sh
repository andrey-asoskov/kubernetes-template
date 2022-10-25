#!/usr/bin/env bash

#Download to host
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
export ETCD_HOST=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)

aws s3 cp --recursive s3://323483035543-k8s-dev/etcd/${ETCD_HOST}/ /tmp/etcd
sudo cp -r /tmp/etcd/pki /etc/kubernetes/

#setup kubelet config
cat << EOF > /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf
[Service]
ExecStart=
# Replace "systemd" with the cgroup driver of your container runtime. The default value in the kubelet is "cgroupfs".
# Replace the value of "--container-runtime-endpoint" for a different container runtime if needed.
ExecStart=/usr/bin/kubelet --address=127.0.0.1 --pod-manifest-path=/etc/kubernetes/manifests --cgroup-driver=systemd --container-runtime=remote --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock
Restart=always
EOF

systemctl daemon-reload
systemctl restart kubelet

#systemctl status kubelet

#Create the static pod manifests
sudo kubeadm init phase etcd local --config=/tmp/etcd/kubeadmcfg.yaml

#check that pods are running
crictl ps -a

#Check the cluster health
sudo docker run --rm -it \
--net host \
-v /etc/kubernetes:/etc/kubernetes registry.k8s.io/etcd:3.4.3-0 etcdctl \
--cert /etc/kubernetes/pki/etcd/peer.crt \
--key /etc/kubernetes/pki/etcd/peer.key \
--cacert /etc/kubernetes/pki/etcd/ca.crt \
--endpoints https://${ETCD_HOST}:2379 endpoint health --cluster
