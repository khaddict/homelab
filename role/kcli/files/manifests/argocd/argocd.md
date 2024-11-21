```
kubectl create namespace argocd
kubectl apply -f cmp-plugin.yaml -n argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install --namespace=argocd argocd argo/argo-cd -f values.yaml --set configs.params."server\.insecure"=true
kubectl apply -f argocd-dashboard-ingressroute.yaml --namespace argocd
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```