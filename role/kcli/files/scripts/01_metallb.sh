#!/bin/bash

export METALLB_NAMESPACE="metallb-system"

helm repo add metallb https://metallb.github.io/metallb
helm repo update

if ! kubectl get namespace $METALLB_NAMESPACE &> /dev/null; then
    echo "Creating namespace $METALLB_NAMESPACE..."
    kubectl create namespace $METALLB_NAMESPACE
else
    echo "Namespace $METALLB_NAMESPACE already exists, skipping creation."
fi

if ! helm status --namespace=$METALLB_NAMESPACE metallb &> /dev/null; then
    echo "Installing Metallb Helm chart..."
    helm install --namespace=$METALLB_NAMESPACE metallb metallb/metallb
    echo "Waiting for Metallb components to initialize..."
    sleep 60
else
    echo "Metallb Helm release already exists, skipping installation."
fi

echo "Applying Metallb configurations..."
kubectl apply -f /root/manifests/metallb/metallb-homelab-pool.yaml --namespace $METALLB_NAMESPACE
kubectl apply -f /root/manifests/metallb/metallb-homelab-l2.yaml --namespace $METALLB_NAMESPACE
