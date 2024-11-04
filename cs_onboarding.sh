#!/bin/bash

# Verifica si la variable de entorno AUTH_TOKEN está configurada
if [ -z "$API_KEY" ]; then
  echo "Error: La variable de entorno AUTH_TOKEN no está configurada."
  exit 1
fi

# Realizar la solicitud a la API y extraer el valor de apiKey
api_key_cs=$(curl --location 'https://api.xdr.trendmicro.com/v3.0/containerSecurity/kubernetesClusters' \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  --header 'Authorization: Bearer $API_KEY' \
  --data '{
    "name": "Demo_Container_PX",
    "groupId": "00000000-0000-0000-0000-000000000000",
    "description": "",
    "policyId": "",
    "resourceId": ""
  }' | jq -r '.apiKey')

# Define la ruta y el nombre del archivo YAML
CONFIG_FILE="/home/ubuntu/CS_DEMO/overrides.yaml"

# Crea el directorio si no existe
mkdir -p "$(dirname "$CONFIG_FILE")"

# Escribe el contenido en el archivo YAML
cat << EOF > "$CONFIG_FILE"
cloudOne: 
    apiKey: $api_key_cs
    endpoint: https://container.us-1.cloudone.trendmicro.com
    exclusion: 
        namespaces: [kube-system]
    runtimeSecurity:
        enabled: true
    vulnerabilityScanning:
        enabled: true
    inventoryCollection:
        enabled: true
    exclusion:
        namespaces:
        - kube-system
        - trendmicro-system
        - calico-system
        - calico-apiserver
        - registry
        - metallb-system
        - tigera-operator
        - local-path-storage
        - ingress-nginx
scout:
  excludeSameNamespace: true
securityContext:
  scout:
    scout:
      allowPrivilegeEscalation: true
      privileged: true
EOF

helm install trendmicro --namespace trendmicro-system --create-namespace --values /home/ubuntu/CS_DEMO/overrides.yaml https://github.com/trendmicro/cloudone-container-security-helm/archive/master.tar.gz

AWS_REGION="us-east-1"
REPOSITORY_NAME="demo-px-repo"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPOSITORY_URI="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY_NAME}"
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

git clone https://github.com/XeniaP/px-container-security-kubernetes.git

export IMAGE_REGISTRY="$REPOSITORY_URI:$IMAGE_TAG"
envsubst < ./px-container-security-kubernetes/${IMAGE_TAG}/deployment-template.yaml | kubectl apply -f -

IMAGE_TAG="flask_app"
docker build -t ${REPOSITORY_NAME}:${IMAGE_TAG} ./px-container-security-kubernetes/${IMAGE_TAG}/
docker tag ${REPOSITORY_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:${IMAGE_TAG}
docker push ${REPOSITORY_URI}:${IMAGE_TAG}

export IMAGE_REGISTRY="$REPOSITORY_URI:$IMAGE_TAG"
envsubst < ./px-container-security-kubernetes/${IMAGE_TAG}/deployment-template.yaml | kubectl apply -f -

IMAGE_TAG="ftp"
docker build -t ${REPOSITORY_NAME}:${IMAGE_TAG} ./px-container-security-kubernetes/${IMAGE_TAG}/
docker tag ${REPOSITORY_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:${IMAGE_TAG}
docker push ${REPOSITORY_URI}:${IMAGE_TAG}

export IMAGE_REGISTRY="$REPOSITORY_URI:$IMAGE_TAG"
envsubst < ./px-container-security-kubernetes/${IMAGE_TAG}/deployment-template.yaml | kubectl apply -f -

IMAGE_TAG="ssh_bastion"
docker build -t ${REPOSITORY_NAME}:${IMAGE_TAG} ./px-container-security-kubernetes/${IMAGE_TAG}/
docker tag ${REPOSITORY_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:${IMAGE_TAG}
docker push ${REPOSITORY_URI}:${IMAGE_TAG}

export IMAGE_REGISTRY="$REPOSITORY_URI:$IMAGE_TAG"
envsubst < ./px-container-security-kubernetes/${IMAGE_TAG}/deployment-template.yaml | kubectl apply -f -
