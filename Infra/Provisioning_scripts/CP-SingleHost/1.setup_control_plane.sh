#!/usr/bin/env bash -x

set -x
set -e

export TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`

export PRIVATE_IP=`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4`
export PUBLIC_IP=`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4`

cp /tmp/scripts/Install-config/audit-policy.yaml /etc/kubernetes/audit-policy.yaml
mkdir -p /var/log/kubernetes/audit

cat << EOF > /tmp/kubeadm-config.yaml
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
clusterName: ${ENV}
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
  - ${PRIVATE_IP} #Private
  - ${PUBLIC_IP} #Public
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
    cloud-provider: aws
    enable-admission-plugins: CertificateApproval,CertificateSigning,CertificateSubjectRestriction,DefaultIngressClass,DefaultStorageClass,DefaultTolerationSeconds,LimitRanger,MutatingAdmissionWebhook,NamespaceLifecycle,PersistentVolumeClaimResize,PodSecurity,Priority,ResourceQuota,RuntimeClass,ServiceAccount,StorageObjectInUseProtection,TaintNodesByCondition,ValidatingAdmissionWebhook,DenyServiceExternalIPs,NodeRestriction,PersistentVolumeLabel
    disable-admission-plugins: PodSecurityPolicy
controllerManager:
  extraArgs: 
    cloud-provider: aws
---    
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
nodeRegistration:
  kubeletExtraArgs:
    cloud-provider: aws
EOF

kubeadm init --config /tmp/kubeadm-config.yaml


#Create config for Worker
export JOIN_TOKEN=$(kubeadm token create)
export API_HOST=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)
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
nodeRegistration:
  kubeletExtraArgs:
    cloud-provider: aws
EOF

#Upload the config
aws s3 cp /etc/kubernetes/admin.conf s3://${CONFIG_S3_BUCKET}/
aws s3 cp /tmp/kubeadm-config-worker.yaml s3://${CONFIG_S3_BUCKET}/





#Test
export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl get nodes -o wide
kubectl get pods -A

#Get join command for workers
#kubeadm token create --print-join-command

