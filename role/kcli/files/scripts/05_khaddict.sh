#!/bin/bash

export KHADDICT_NAMESPACE="khaddict"

export VAULT_TOKEN={{ vault_token }}
export VAULT_ADDR="https://vault.homelab.lan:8200/"

export KHADDICT_CERT_SECRET=$(vault kv get -tls-skip-verify -field="khaddict.homelab.lan.crt" "kv/ca/applications/khaddict.homelab.lan")
export KHADDICT_KEY_SECRET=$(vault kv get -tls-skip-verify -field="khaddict.homelab.lan.key" "kv/ca/applications/khaddict.homelab.lan")

echo "$KHADDICT_CERT_SECRET" > /tmp/khaddict.crt
echo "$KHADDICT_KEY_SECRET" > /tmp/khaddict.key

if ! kubectl get namespace $KHADDICT_NAMESPACE &> /dev/null; then
    echo "Creating namespace $KHADDICT_NAMESPACE..."
    kubectl create namespace $KHADDICT_NAMESPACE
else
    echo "Namespace $KHADDICT_NAMESPACE already exists, skipping creation."
fi

kubectl create secret tls khaddict-cert-secret \
    --namespace khaddict \
    --cert=/tmp/khaddict.crt \
    --key=/tmp/khaddict.key

rm /tmp/khaddict.crt /tmp/khaddict.key

kubectl apply -f /root/manifests/khaddict.com/argocdapp-khaddict.com.yaml
kubectl apply -f /root/manifests/khaddict.com/khaddict.com-ingressroute.yaml
