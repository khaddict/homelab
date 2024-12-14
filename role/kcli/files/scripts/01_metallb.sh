#!/bin/bash

export METALLB_NAMESPACE="metallb-system"

helm repo add metallb https://metallb.github.io/metallb
helm repo update
kubectl create namespace $METALLB_NAMESPACE
helm install --namespace=$METALLB_NAMESPACE metallb metallb/metallb
sleep 30
kubectl apply -f /root/manifests/metallb/metallb-homelab-pool.yaml --namespace $METALLB_NAMESPACE
kubectl apply -f /root/manifests/metallb/metallb-homelab-l2.yaml --namespace $METALLB_NAMESPACE
