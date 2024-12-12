#!/bin/bash

export TRAEFIK_NAMESPACE="traefik"
export VAULT_TOKEN={{ vault_token }}
export VAULT_ADDR="https://vault.homelab.lan:8200/"

helm repo add traefik https://traefik.github.io/charts
helm repo update
kubectl create namespace $TRAEFIK_NAMESPACE
helm install traefik traefik/traefik --namespace $TRAEFIK_NAMESPACE --set dashboard.enabled=true --set service.type=LoadBalancer
export TRAEFIK_DASHBOARD_SECRET=(vault kv get -tls-skip-verify -field="traefik_dashboard_secret" "kv/kubernetes")
export TRAEFIK_DASHBOARD_SECRET_HTPASSWD=$(htpasswd -nb admin "$TRAEFIK_DASHBOARD_SECRET" | base64)

kubectl create secret generic traefik-dashboard-secret \
    --namespace $TRAEFIK_NAMESPACE \
    --from-literal=users=$TRAEFIK_DASHBOARD_SECRET_HTPASSWD

kubectl apply -f traefik-dashboard-ingressroute.yaml \
    --namespace $TRAEFIK_NAMESPACE

kubectl apply -f traefik-dashboard-middleware.yaml \
    --namespace $TRAEFIK_NAMESPACE
