```
helm repo add metallb https://metallb.github.io/metallb
helm repo update
helm install --namespace=metallb-system metallb metallb/metallb --create-namespace
kubectl apply -f metallb-homelab-pool.yaml --namespace metallb-system
kubectl apply -f metallb-homelab-l2.yaml --namespace metallb-system
```