#!/bin/bash

# Initialize the cluster
kubeadm init --pod-network-cidr=172.16.0.0/12

# Get join command for worker nodes
kubeadm token create --print-join-command > /kubeadm/join-command.sh

# Copy kubeconfig to vagrant user
cp -r /root/.kube /home/vagrant/
chown -R vagrant:vagrant .kube

# # Install Calico networking
# kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
# # Install ingress-nginx
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
# # Install cert-manager
# kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.1/cert-manager.yaml

# # wait for ingress-nginx to be ready
# kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s

# GITHUB_USERNAME=Ward-Smeyers
# GITHUB_TOKEN=$(cat /kubeadm/.ghcr.io_token)
# kubectl create secret docker-registry ghcr-login-secret --docker-server=https://ghcr.io --docker-username=$GITHUB_USERNAME --docker-password=$GITHUB_TOKEN 

# # Apply k8s resources
# kubectl apply -f /app/deployment.yaml
# kubectl apply -f /app/service.yaml
# kubectl apply -f /app/ingress.yaml

# Add kubectl alias and kcc function to .bashrc
echo '
# add alias for kubectl
alias k="kubectl"
alias kg="kubectl get"
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
