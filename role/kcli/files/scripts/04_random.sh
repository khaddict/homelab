#!/bin/bash

export VAULT_TOKEN={{ vault_token }}
export VAULT_ADDR="https://vault.homelab.lan:8200/"

# Hubble certificate & ingressroute
export HUBBLE_NAMESPACE="kube-system"

export HUBBLE_CERT_SECRET=$(vault kv get -tls-skip-verify -field="hubble.homelab.lan.crt" "kv/ca/applications/hubble.homelab.lan")
export HUBBLE_KEY_SECRET=$(vault kv get -tls-skip-verify -field="hubble.homelab.lan.key" "kv/ca/applications/hubble.homelab.lan")

echo "$HUBBLE_CERT_SECRET" > /tmp/hubble.crt
echo "$HUBBLE_KEY_SECRET" > /tmp/hubble.key

kubectl create secret tls hubble-cert-secret \
    --namespace $HUBBLE_NAMESPACE \
    --cert=/tmp/hubble.crt \
    --key=/tmp/hubble.key

rm /tmp/hubble.crt /tmp/hubble.key

kubectl apply -f /root/apps/cilium/cilium_ingressroute.yaml

# Apply homelab-app-of-apps.yaml
kubectl apply -f /root/homelab_cloud/homelab-app-of-apps.yaml
