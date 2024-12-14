#!/bin/bash

export TRAEFIK_NAMESPACE="traefik"
export VAULT_TOKEN={{ vault_token }}
export VAULT_ADDR="https://vault.homelab.lan:8200/"

helm repo add traefik https://traefik.github.io/charts
helm repo update

if ! kubectl get namespace $TRAEFIK_NAMESPACE &> /dev/null; then
    echo "Creating namespace $TRAEFIK_NAMESPACE..."
    kubectl create namespace $TRAEFIK_NAMESPACE
else
    echo "Namespace $TRAEFIK_NAMESPACE already exists, skipping creation."
fi

if ! helm status --namespace=$TRAEFIK_NAMESPACE traefik &> /dev/null; then
    echo "Installing Traefik Helm chart..."
    helm install traefik traefik/traefik --namespace $TRAEFIK_NAMESPACE --set dashboard.enabled=true --set service.type=LoadBalancer
    echo "Waiting for Traefik components to initialize..."
    sleep 30
else
    echo "Traefik Helm release already exists, skipping installation."
fi

export TRAEFIK_DASHBOARD_SECRET=$(vault kv get -tls-skip-verify -field="traefik_dashboard_secret" "kv/kubernetes")
export TRAEFIK_DASHBOARD_SECRET_HTPASSWD=$(htpasswd -nb admin "$TRAEFIK_DASHBOARD_SECRET" | base64)

kubectl create secret generic traefik-dashboard-secret \
    --namespace $TRAEFIK_NAMESPACE \
    --from-literal=users=$TRAEFIK_DASHBOARD_SECRET_HTPASSWD

kubectl apply -f /root/manifests/traefik/traefik-dashboard-ingressroute.yaml \
    --namespace $TRAEFIK_NAMESPACE

kubectl apply -f /root/manifests/traefik/traefik-dashboard-middleware.yaml \
    --namespace $TRAEFIK_NAMESPACE
