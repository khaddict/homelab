```
helm repo add traefik https://traefik.github.io/charts
helm repo update
helm install traefik traefik/traefik --namespace traefik --set dashboard.enabled=true --set service.type=LoadBalancer
htpasswd -nb admin "password123+" | base64 -> placer le mot de passe dans traefik-dashboard-secret.yaml
kubectl apply -f traefik-dashboard-ingressroute.yaml --namespace traefik
kubectl apply -f traefik-dashboard-secret.yaml --namespace traefik
kubectl apply -f traefik-dashboard-middleware.yaml --namespace traefik
```