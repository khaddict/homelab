#!/bin/bash

# dnsutils

export TOOLS_NAMESPACE="tools"

kubectl create namespace $TOOLS_NAMESPACE
kubectl apply -f /root/manifests/tools/dnsutils.yaml --namespace $TOOLS_NAMESPACE
