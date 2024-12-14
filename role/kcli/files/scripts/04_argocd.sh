#!/bin/bash

export ARGOCD_NAMESPACE="argocd"
export VAULT_TOKEN={{ vault_token }}
export VAULT_ADDR="https://vault.homelab.lan:8200/"

kubectl create namespace $ARGOCD_NAMESPACE
kubectl apply -f /root/manifests/argocd/cmp-plugin.yaml -n $ARGOCD_NAMESPACE
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

helm install --namespace=$ARGOCD_NAMESPACE argocd argo/argo-cd -f /root/manifests/argocd/values.yaml -f /root/manifests/argocd/overrides.yaml --set configs.params."server\.insecure"=true
sleep 40
kubectl apply -f /root/manifests/argocd/argocd-dashboard-ingressroute.yaml --namespace $ARGOCD_NAMESPACE
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d