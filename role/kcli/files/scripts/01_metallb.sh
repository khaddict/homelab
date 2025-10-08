#!/bin/bash

export METALLB_NAMESPACE="metallb-system"
export VERSION="0.15.2"

helm repo add metallb https://metallb.github.io/metallb
helm repo update

if ! kubectl get namespace $METALLB_NAMESPACE &> /dev/null; then
    echo "Creating namespace $METALLB_NAMESPACE..."
    kubectl create namespace $METALLB_NAMESPACE
else
    echo "Namespace $METALLB_NAMESPACE already exists, skipping creation."
fi

echo "Installing/Upgrading Metallb Helm chart to version $VERSION..."
helm upgrade --install --namespace=$METALLB_NAMESPACE metallb metallb/metallb --version $VERSION

echo "Waiting for Metallb components to initialize..."
sleep 60

echo "Applying Metallb configurations..."
kubectl apply -f /root/apps/metallb/metallb_pool.yaml --namespace $METALLB_NAMESPACE
kubectl apply -f /root/apps/metallb/metallb_l2.yaml --namespace $METALLB_NAMESPACE
