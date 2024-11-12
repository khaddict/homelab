```
helm repo add metallb https://metallb.github.io/metallb
helm repo update
helm install --namespace=metallb metallb metallb/metallb --create-namespace
kubectl apply -f metallb-config.yaml --namespace metallb
```