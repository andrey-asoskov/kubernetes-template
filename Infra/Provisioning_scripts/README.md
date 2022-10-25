# Manual k8s installation

## etcd

1. Start 3 nodes to get 3 IP addreses
2. Put IP addresses and hostnames to script "scripts/etcd/1.create_etcd_config.sh" and "scripts/etcd/2.create-etcd_certs.sh"
3. Upload new scripts to S3 via re-running terraform: 

```
terraform apply
```

4. Download new scripts on first node and run all of them: 

```
aws s3 cp s3://323483035543-k8s-dev/scripts.zip /tmp/
unzip -o /tmp/scripts.zip -d /tmp/scripts
cd /tmp/scripts/etcd
./1.create_etcd_config.sh
./2.create-etcd_certs.sh
./3.setup_kubelet_etcd.sh
```

5. Run script "scripts/etcd/3.setup_kubelet_etcd.sh" on each node 

```
cd /tmp/scripts/etcd
./3.setup_kubelet_etcd.sh
```



## Control plane

1. Start 3 nodes to get IP addresses
2. Put IP addresses to haproxy.cfg 
3. Put any ETCD IP address, LB IP address, all ETCD IP addresses to script "scripts/control_plane/1.setup_control_plane.sh"
4. Upload new scripts to S3 via re-running terraform for ETCD: 

```
cd ../Etcd
terraform apply -auto-approve
```

5. Download new scripts on LB and all Control_plane nodes: 

```
aws s3 cp s3://323483035543-k8s-dev/scripts.zip /tmp/
unzip -o /tmp/scripts.zip -d /tmp/scripts
cd /tmp/scripts
```

6. Restart LB

```
cp /tmp/scripts/lb/haproxy.cfg /etc/haproxy/haproxy.cfg
systemctl restart haproxy
```

7. Run script "scripts/control_plane/1.setup_control_plane.sh" on first Control_plane node 
8. Run join command on other Control_plane nodes:

```
  kubeadm join 10.1.2.117:6443 --token 1s96st.qw61bt1n6i7b1qww \
        --discovery-token-ca-cert-hash sha256:3673ae87c51e620e3492d2ae3226eb862b63b1a0364b919e8d1aff14868b21c6 \
        --control-plane --certificate-key 6b1d29fd151c4722840af2d918b4491c683702beb4cf192bbedea36e8d517abb \
        --config /tmp/kubeadm-config.yaml
```

9. Setup Calico via running the script "scripts/control_plane/2.setup_calico.sh" on any node


## Worker
1. Start 3 nodes
aws s3 rm s3://323483035543-k8s-dev --recursive --profile flashslash



## Connect from local
aws s3 cp s3://323483035543-k8s-dev/admin.conf ~/.kube/dev-cluster.config --profile flashslash

#update IP in  ~/.kube/dev-cluster.config
vim  ~/.kube/dev-cluster.config

export KUBECONFIG=~/.kube/dev-cluster.config

kubectl get nodes

