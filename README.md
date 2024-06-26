# Mon homelab

## Introduction

L'objectif de ce projet, c'est de me faire un p'tit homelab pour tester plein de trucs.

## Matériel

- GEEKOM Mini IT13 Mini-PC Intel Core i9 upgrade à 64Go : https://www.geekom.fr/geekom-mini-it13-mini-pc/
- Raspberry Pi 5 8GB x2 : https://www.raspberrypi.com/products/raspberry-pi-5/
- TP-Link TL-SG108E Switch Ethernet 8 Ports Gigabit : https://www.amazon.fr/gp/product/B00JKB63D8

### Fait

- ✅ `master.homelab.lan` : machine "test" sur laquelle il est possible de faire un peu n'importe quoi (des curl, des boucles...) + git installé dessus pour gérer les repo GitHub
- ✅ `saltmaster.homelab.lan` : saltmaster qui pilote ses minions → gestion de configurations
- ✅ `pi-hole01.homelab.lan` : premier Pi-hole pour gérer la partie DNS + adblocker. Entrées DNS gérées directement via le fichier `/etc/pihole/custom.list`
- ✅ `pi-hole02.homelab.lan` : deuxième Pi-hole
- ✅ `stackstorm.homelab.lan` :  stackstorm permet de gérer les automatisations
- ✅ `vault.homelab.lan` : machine Vault pour stocker les secrets qui doivent être récupérables via SaltStack
- ✅ `netbox.homelab.lan` : machine NetBox pour l'inventaire des ressources + permet de récupérer pour réutiliser certaines variables dans des workflows StackStorm 
- ✅ `web01.homelab.lan` : premier serveur web (contenu pas important pour le moment)
- ✅ `web02.homelab.lan` : deuxième serveur web équivalent au premier
- ✅ `ha01.homelab.lan` : premier HAProxy + Keepalived pour gérer la HA sur les serveurs web (la VIP : `web.homelab.lan`)
- ✅ `ha02.homelab.lan` : deuxième HAProxy + Keepalived
- ✅ `ldap.homelab.lan` : machine LDAP + PHPLDAPAdmin
- ✅ `prometheus.homelab.lan` : machine Prometheus x alertmanager pour la partie monitoring & alerting (redirections vers Discord)
- ✅ `grafana.homelab.lan` : machine Grafana
- ✅ `ca.homelab.lan` : machine CA qui gère les certificats SSL via openSSL
- ✅ `ntp.homelab.lan` : machine NTP → chrony
- ✅ `elk.homelab.lan` : machine ELK + rsyslog

### En cours

- Remettre un peu salt au propre
- Automatiser la création d'une VM + création côté NetBox
- Mettre tous mes services en HTTPS
- Automatiser l'envoi des certs vers Vault (+ mettre les existants)
- Intégration Vault / Saltstack obsolète, besoin de changer
- Gérer quelle machine peut se connecter à laquelle (actuellement openbar)

### Après

- `pfsense.homelab.lan` : PfSense pour gérer la partie firewall
- `smtp.homelab.lan` : machine SMTP
- `cloud.homelab.lan` : mettre en place une partie cloud pour apprendre des solutions comme Kubernetes, Docker
- `ansible.homelab.lan` : mettre en place une partie de l'automatisation avec Ansible pour apprendre les basiques
- `terraform.homelab.lan` : mettre en place une partie de l'automatisation avec Terraform pour apprendre les basiques
