#!/bin/bash

export TOOLS_NAMESPACE="tools"

if ! kubectl get namespace $TOOLS_NAMESPACE &> /dev/null; then
    echo "Creating namespace $TOOLS_NAMESPACE..."
    kubectl create namespace $TOOLS_NAMESPACE
else
    echo "Namespace $TOOLS_NAMESPACE already exists, skipping creation."
fi

kubectl apply -f /root/manifests/tools/dnsutils.yaml --namespace $TOOLS_NAMESPACE
