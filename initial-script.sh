#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

sudo apt-get update -y
sudo apt-get upgrade -y || true

sudo apt-get install -y libbtrfs-dev git libassuan-dev libglib2.0-dev libc6-dev libgpgme-dev libgpg-error-dev libseccomp-dev libsystemd-dev libselinux1-dev pkg-config go-md2man libudev-dev software-properties-common gcc make unzip jq docker.io

ufw allow 6443/tcp #apiserver
ufw allow from 10.42.0.0/16 to any #pods
ufw allow from 10.43.0.0/16 to any #services

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
#sudo ./aws/install --update

sudo snap install helm --classic || true
sudo snap install kubectl --classic || true
sudo apt-get install docker.io -y || true
sudo apt install -y unzip jq

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
TAGS=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s "http://169.254.169.254/latest/meta-data/tags/instance")
NODE_TYPE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s "http://169.254.169.254/latest/meta-data/tags/instance/Node-Type")

if [ "$NODE_TYPE" == "Master" ]; then
    echo "NODE MASTER"
    curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --cluster-init
    aws ssm put-parameter --name "/k3s/cluster/CS-token" --value "$(cat /var/lib/rancher/k3s/server/node-token)" --type SecureString --overwrite
    aws ssm put-parameter --name "/k3s/cluster/CS-master-ip" --value "$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s "http://169.254.169.254/latest/meta-data/local-ipv4")" --type String --overwrite
    INSTANCE_ID="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"  # Reemplaza con el ID de la instancia
    VPC_ID=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].VpcId" --output text)
    TAG_NAME="Nodek3sInstance"
    INSTANCE_IDS=$(aws ec2 describe-instances --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=$TAG_NAME" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].InstanceId" --output text)
    KS_TOKEN=$(aws ssm get-parameter --name "/k3s/cluster/CS-token" --with-decryption --query "Parameter.Value" --output text)
    MASTER_IP=$(aws ssm get-parameter --name "/k3s/cluster/CS-master-ip" --query "Parameter.Value" --output text)
    SERVER_URL="https://$MASTER_IP:6443"
    COMMAND="curl -sfL https://get.k3s.io | K3S_URL=$SERVER_URL K3S_TOKEN=$KS_TOKEN sh -"
    SHARED_KUBE_DIR="/usr/local/share/kube"
    KUBECONFIG_PATH="$SHARED_KUBE_DIR/config"
    sudo mkdir -p $SHARED_KUBE_DIR
    sudo cp /etc/rancher/k3s/k3s.yaml $KUBECONFIG_PATH
    sudo chmod 644 $KUBECONFIG_PATH
    if ! grep -q "export KUBECONFIG=$KUBECONFIG_PATH" /etc/profile; then
        echo "export KUBECONFIG=$KUBECONFIG_PATH" | sudo tee -a /etc/profile
    fi
    source /etc/profile
fi
