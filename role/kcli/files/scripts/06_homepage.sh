#!/bin/bash

export HOMEPAGE_NAMESPACE="homepage"

export VAULT_TOKEN={{ vault_token }}
export VAULT_ADDR="https://vault.homelab.lan:8200/"

export HOMEPAGE_CERT_SECRET=$(vault kv get -tls-skip-verify -field="homepage.homelab.lan.crt" "kv/ca/applications/homepage.homelab.lan")
export HOMEPAGE_KEY_SECRET=$(vault kv get -tls-skip-verify -field="homepage.homelab.lan.key" "kv/ca/applications/homepage.homelab.lan")

echo "$HOMEPAGE_CERT_SECRET" > /tmp/homepage.crt
echo "$HOMEPAGE_KEY_SECRET" > /tmp/homepage.key

if ! kubectl get namespace $HOMEPAGE_NAMESPACE &> /dev/null; then
    echo "Creating namespace $HOMEPAGE_NAMESPACE..."
    kubectl create namespace $HOMEPAGE_NAMESPACE
else
    echo "Namespace $HOMEPAGE_NAMESPACE already exists, skipping creation."
fi

kubectl create secret tls homepage-cert-secret \
    --namespace $HOMEPAGE_NAMESPACE \
    --cert=/tmp/homepage.crt \
    --key=/tmp/homepage.key

rm /tmp/homepage.crt /tmp/homepage.key

kubectl apply -f /root/manifests/homepage/argocdapp-homepage.yaml
kubectl apply -f /root/manifests/homepage/homepage-ingressroute.yaml
