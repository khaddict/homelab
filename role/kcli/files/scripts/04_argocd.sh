#!/bin/bash

export ARGOCD_NAMESPACE="argocd"
export VAULT_TOKEN={{ vault_token }}
export VAULT_ADDR="https://vault.homelab.lan:8200/"

if ! kubectl get namespace $ARGOCD_NAMESPACE &> /dev/null; then
    echo "Creating namespace $ARGOCD_NAMESPACE..."
    kubectl create namespace $ARGOCD_NAMESPACE
else
    echo "Namespace $ARGOCD_NAMESPACE already exists, skipping creation."
fi

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

kubectl create secret generic vault-configuration \
    --namespace $ARGOCD_NAMESPACE \
    --from-literal=VAULT_ADDR=$VAULT_ADDR \
    --from-literal=VAULT_TOKEN=$VAULT_TOKEN \
    --from-literal=AVP_AUTH_TYPE=token \
    --from-literal=AVP_TYPE=vault

kubectl create secret generic ca-homelab-secret \
    --namespace $ARGOCD_NAMESPACE \
    --from-file=ca-homelab.crt=/usr/local/share/ca-certificates/ca-homelab.crt

if ! helm status --namespace=$ARGOCD_NAMESPACE argocd &> /dev/null; then
    echo "Installing ArgoCD Helm chart..."
    helm install --namespace=$ARGOCD_NAMESPACE argocd argo/argo-cd -f /root/manifests/argocd/values.yaml -f /root/manifests/argocd/overrides.yaml --set configs.params."server\.insecure"=true
    echo "Waiting for ArgoCD components to initialize..."
    sleep 40
else
    echo "ArgoCD Helm release already exists, skipping installation."
fi

kubectl apply -f /root/manifests/argocd/argocd-dashboard-ingressroute.yaml --namespace $ARGOCD_NAMESPACE
kubectl delete secret argocd-initial-admin-secret -n $ARGOCD_NAMESPACE

export ARGOCD_PASSWORD_BCRYPT=$(vault kv get -tls-skip-verify -field="argocd_dashboard_password_bcrypt" "kv/kubernetes")

ARGOCD_SERVER_POD=$(kubectl get pods -n $ARGOCD_NAMESPACE | grep -i "argocd-server" | awk '{print $1}')
ARGOCD_SERVER=$(kubectl get svc argocd-server -n $ARGOCD_NAMESPACE -o json | jq -r .spec.clusterIP)

kubectl -n $ARGOCD_NAMESPACE patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "'$ARGOCD_PASSWORD_BCRYPT'",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'
