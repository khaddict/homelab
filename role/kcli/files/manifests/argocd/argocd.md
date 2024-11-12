```
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install --namespace=argocd argocd argo/argo-cd --create-namespace --set configs.params."server\.insecure"=true
kubectl apply -f argocd-dashboard-ingressroute.yaml --namespace argocd
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```