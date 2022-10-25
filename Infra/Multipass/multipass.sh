#Start CP
multipass launch -n cp -c 2 -m 4G  -d 10G \
--cloud-init cloud-config-cp.yaml \
--mount ../Provisioning_scripts:/mnt \
22.04

multipass shell cp
sudo -i
cd /mnt

bash ./Kubeadm/1.setup_kubeadm_prereq.sh
bash ./Container_runtime/2-1.setup_container_prereq.sh 
bash ./Container_runtime/2-2.install_docker_containerd.sh 
bash ./Container_runtime/2-3.configure_containderd.sh
bash ./Kubeadm/2.install_kubeadm.sh



cp ./Install-config/audit-policy.yaml /etc/kubernetes/audit-policy.yaml
mkdir -p /var/log/kubernetes/audit

ip a s

cat << EOF > /tmp/kubeadm-config.yaml
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
clusterName: multipass
certificatesDir: /etc/kubernetes/pki
kubernetesVersion: "1.24.5"
networking:
  dnsDomain: cluster.local
  serviceSubnet: "10.96.0.0/12"
  podSubnet: "192.168.0.0/16"
etcd:
  local:
    dataDir: /var/lib/etcd
apiServer:
  certSANs:
  - 127.0.0.1
  - 192.168.64.6 #Private
  extraVolumes:
    - name: audit-config
      hostPath: /etc/kubernetes/audit-policy.yaml
      mountPath: /etc/kubernetes/audit-policy.yaml
      readOnly: true
      pathType: File
    - name: audit-log
      hostPath: /var/log/kubernetes/audit/
      mountPath: /var/log/kubernetes/audit/
      readOnly: false
      pathType: DirectoryOrCreate
  extraArgs:
    advertise-address: 0.0.0.0
    anonymous-auth: "true"
    authorization-mode: "Node,RBAC"
    audit-policy-file: /etc/kubernetes/audit-policy.yaml
    audit-log-path: /var/log/kubernetes/audit/audit.log
    audit-log-maxage: "7"
    enable-admission-plugins: CertificateApproval,CertificateSigning,CertificateSubjectRestriction,DefaultIngressClass,DefaultStorageClass,DefaultTolerationSeconds,LimitRanger,MutatingAdmissionWebhook,NamespaceLifecycle,PersistentVolumeClaimResize,PodSecurity,Priority,ResourceQuota,RuntimeClass,ServiceAccount,StorageObjectInUseProtection,TaintNodesByCondition,ValidatingAdmissionWebhook,DenyServiceExternalIPs,NodeRestriction,PersistentVolumeLabel
    disable-admission-plugins: PodSecurityPolicy
EOF

kubeadm init --config /tmp/kubeadm-config.yaml

#Create config for Worker
export JOIN_TOKEN=$(kubeadm token create)
export API_HOST=192.168.64.6
export CA_CERT_HASH=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')

cat << EOF > /tmp/kubeadm-config-worker.yaml
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: JoinConfiguration
discovery:
  bootstrapToken:
    token: ${JOIN_TOKEN}
    apiServerEndpoint: "${API_HOST}:6443"
    caCertHashes: ["sha256:${CA_CERT_HASH}"]
EOF

bash ./3.setup_calico.sh
bash ./setup_kubectl.sh

export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl get nodes -o wide
kubectl get pods -A

cp  /tmp/kubeadm-config-worker.yaml /mnt/Temp_for_multipass
cp  /etc/kubernetes/admin.conf /mnt/Temp_for_multipass



multipass stop cp 
multipass start cp

#To delete
multipass delete --purge cp && multipass purge








### Worker

#Start Worker
multipass launch -n worker1 -c 2 -m 4G -d 10G \
--mount ../Provisioning_scripts:/mnt \
22.04

multipass shell worker1 

#!!! Do the Steps from CP

kubeadm join  \
        --config /mnt/Temp_for_multipass/kubeadm-config-worker.yaml

bash ./setup_kubectl.sh


#To delete
multipass delete --purge worker1 && multipass purge

multipass stop worker1 
multipass start worker1

# To use
export KUBECONFIG=./Infra/Provisioning_scripts/Temp_for_multipass/admin.conf 
kubectl get pod -A
