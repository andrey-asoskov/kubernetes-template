#!/usr/bin/env bash

containerd config default > /etc/containerd/config.toml

sed -i -e 's/disabled_plugins = \[\"cri\"\]/disabled_plugins = \[\]/g' /etc/containerd/config.toml

#echo '
#version = 2
#[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
#  SystemdCgroup = true' >> /etc/containerd/config.toml

sed -i -e 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

cat << EOF | tee /etc/cni/net.d/10-containerd-net.conflist
{
 "cniVersion": "1.0.0",
 "name": "containerd-net",
 "plugins": [
   {
     "type": "bridge",
     "bridge": "cni0",
     "isGateway": true,
     "ipMasq": true,
     "promiscMode": true,
     "ipam": {
       "type": "host-local",
       "ranges": [
         [{
           "subnet": "10.88.0.0/16"
         }],
         [{
           "subnet": "2001:db8:4860::/64"
         }]
       ],
       "routes": [
         { "dst": "0.0.0.0/0" },
         { "dst": "::/0" }
       ]
     }
   },
   {
     "type": "portmap",
     "capabilities": {"portMappings": true}
   }
 ]
}
EOF

sudo systemctl restart containerd
