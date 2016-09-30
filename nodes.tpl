#cloud-config
# vim: syntax=yaml

package_upgrade: true

write_files:
  - path: /etc/systemd/system/docker.service.d/10-storage-driver.conf
    owner: root:root
    permissions: 0644
    content: |
      [Service]
      ExecStart=
      ExecStart=/usr/bin/dockerd -H fd:// --storage-driver=overlay

packages:
  - apt-transport-https
  - ca-certificates
  - gnupg2
  - awscli

runcmd:
  - aws ec2 modify-instance-attribute --no-source-dest-check --region eu-west-1 --instance-id $(curl -sL http://169.254.169.254/latest/meta-data/instance-id)
  - apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 0xF76221572C52609D 0x3746C208A7317B0F
  - echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list
  - echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  - apt-get update && apt-get install -y docker-engine kubelet kubeadm kubectl kubernetes-cni
  - systemctl daemon-reload
  - systemctl enable docker
  - systemctl enable kubelet
  - systemctl start docker
  - sleep 120 && for i in $(seq 10); do echo "kubeadm join $i" && kubeadm join --token=${k8s_token} ${control_plane_ip} && break || sleep 15; done

output: { all : '| tee -a /var/log/cloud-init-output.log' }

final_message: "The system is finally up, after $UPTIME seconds"
