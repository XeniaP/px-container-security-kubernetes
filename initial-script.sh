#!/bin/bash

sudo apt update && sudo apt upgrade

sudo apt-get install -y libbtrfs-dev containers-common git libassuan-dev libglib2.0-dev libc6-dev libgpgme-dev libgpg-error-dev libseccomp-dev libsystemd-dev libselinux1-dev pkg-config go-md2man cri-o-runc libudev-dev software-properties-common gcc make 

sudo apt install -y unzip jq

ufw allow 6443/tcp #apiserver
ufw allow from 10.42.0.0/16 to any #pods
ufw allow from 10.43.0.0/16 to any #services

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
sudo ./aws/install --update

sudo snap install helm --classic
sudo snap install kubectl --classic
sudo apt install -y docker.io

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

TAGS=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s "http://169.254.169.254/latest/meta-data/tags/instance")

TAG_VALUE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s "http://169.254.169.254/latest/meta-data/tags/instance/Name")

echo "Instance tags: $TAGS"
echo "Value of the 'Name' tag: $TAG_VALUE"

if [ "$TAG_VALUE" == "Master" ]; then
    curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --cluster-init
    aws ssm put-parameter --name "/k3s/cluster/token" --value "$(cat /var/lib/rancher/k3s/server/node-token)" --type SecureString
else
    TOKEN=$(aws ssm get-parameter --name "/k3s/cluster/token" --with-decryption --query "Parameter.Value" --output text)
    SERVER_URL="https://<IP_O_DNS_DEL_SERVER>:6443"
    curl -sfL https://get.k3s.io | K3S_URL=$SERVER_URL K3S_TOKEN=$TOKEN sh -s - server --cluster-init --disable-apiserver --disable-controller-manager --disable-scheduler
fi





