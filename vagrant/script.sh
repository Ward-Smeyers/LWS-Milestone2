#!/bin/bash

# Set timezone and enable ntp
timedatectl set-timezone Europe/Brussels
timedatectl set-ntp true

# Add Docker's official GPG key:
apt-get update
apt-get install -y ca-certificates curl virtualbox-guest-utils
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

# Install docker tools
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Login to docker hub, recwiers .docker_password file vagrant synced_folder
cat /vagrant/.docker_password | docker login --username automator2 --password-stdin

# Add docker group and add vagrant user to docker group
newgrp docker
usermod -aG docker vagrant
groups vagrant


su vagrant
cd /home/vagrant

# Install kind
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

# Install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Add alias to 
echo '
# add alias for docker
alias d="docker $@"
alias dc="docker compose $@"
alias dcu="docker compose up -d"
alias dcb="docker compose up -d --build"
alias dcd="docker compose down"
alias dcr="docker compose restart"

# add alias for kubectl
alias k="kubectl"
alias kgn="kubectl get nodes"
alias kp="kubectl get pods"
alias kdp="kubectl describe pod"
alias ksvc="kubectl get svc"
alias kcc="kcc $context $@"

# Credits to InAnimaTe https://gist.github.com/InAnimaTe/eeeb4b01467d74c522b94f12ed009889
function kcc () {
    usage () {
        echo -en "Usage: $0 <context> <namespace>\n"
    }
    result () {
        echo -en "-> Context: \e[96m$context\e[0m\n-> Namespace: \e[92m$namespace\n\e[0m"
    }
    if  [ $# -eq 0 ] ; then
        ## If no options, print the current context/cluster and namespace
        context="$(kubectl config current-context 2>/dev/null)"
        namespace="$(kubectl config view -o "jsonpath={.contexts[?(@.name==\"$context\")].context.namespace}")"
        result
    elif [ $# -eq 2 ]; then
        ## If options, assume time to set
        context="$1"
        namespace="$2"
        kubectl config use-context "$context" > /dev/null
        kubectl config set-context "$context" --namespace="$namespace" > /dev/null
        result
    else
        usage
    fi
}'>> /home/vagrant/.bashrc

# Create kind cluster
kind delete cluster
kind create cluster --config=/vagrant/kindconfig
kind get clusters

# Copy kubeconfig to vagrant user
cp -r /root/.kube /home/vagrant/
chown -R vagrant:vagrant .kube

# Install ingress-nginx
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.1/cert-manager.yaml

# Wait for ingress-nginx to be ready
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s

# Create secret for ghcr.io login (github container registry)
GITHUB_USERNAME=Ward-Smeyers
GITHUB_TOKEN=$(cat /vagrant/.ghcr.io_token)
kubectl create secret docker-registry ghcr-login-secret --docker-server=https://ghcr.io --docker-username=$GITHUB_USERNAME --docker-password=$GITHUB_TOKEN 

# Apply k8s resources
kubectl apply -f /app/deploy
