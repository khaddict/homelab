# My Homelab

## 1) Introduction 👨🏻‍💻

The goal of this project is to experiment and practice on a daily basis with technologies used as a Site Reliability Engineer (SRE), to set up personal projects, and, of course, to have my own little data center at home (because that's cool, right?).

## 2) Hardware 🛰

- `[x3] GEEKOM Mini IT13 Mini-PC Intel Core i9 upgraded to 64GB` ➞ [Link](https://www.geekom.fr/geekom-mini-it13-mini-pc/)
- `[x1] TP-Link TL-SG108E 8-Port Gigabit Ethernet Switch` ➞ [Link](https://www.tp-link.com/fr/business-networking/easy-smart-switch/tl-sg108e/)

## 3) Issues 📝

Issues are written in both English and French for convenience.<br>
I use them to write down ideas and things to do, and it's often easier to do this in my native language.

📍 [Homelab issues](https://github.com/khaddict/homelab/issues)

## 4) System and Network Architecture Diagram 🌐

For now, I'll summarize my setup with a screenshot of my homepage.<br>
A proper system and network architecture diagram will be added later (when I have time to make it clean and organized).

![image](https://github.com/user-attachments/assets/34d3af20-d285-4984-bb89-580f5b5441e1)

## 5) Infrastructure Overview 🌟

![image](https://github.com/user-attachments/assets/30f609d1-74c2-4b75-bbcc-80f2a8fd390c)

I have a three-node Proxmox cluster running virtual machines. Most of these VMs are managed with SaltStack. The technologies used include:

- 🔐 `main.homelab.lan` ➞ The main entry point to my infrastructure.<br>
  - All SSH access to other machines is blocked by default.
  - This machine can access all others and is actively monitored.
  - Any connection from a non-whitelisted IP triggers a Discord notification.
  - It is also responsible for pushing changes to GitHub and pulling updates for `/srv/salt` to `saltmaster.homelab.lan` upon receiving push events.

- 🧂 `saltmaster.homelab.lan` ➞ [SaltStack](https://saltproject.io)<br>
  - The Salt master manages all my minions (other VMs).
  - Whenever something is pushed to GitHub, `main.homelab.lan` pulls `/srv/salt` from this machine to apply state configurations.

- 🤖 `stackstorm.homelab.lan` ➞ [StackStorm](https://stackstorm.com)<br>
  - Automates various actions, including VM creation, SSL certificate generation, resource provisioning in NetBox, PowerDNS automation, and more.

- 📦 `netbox.homelab.lan` ➞ [NetBox](https://netboxlabs.com)<br>
  - Inventory of all homelab resources: IP addresses, VMs, network interfaces, etc.

- 🔑 `vault.homelab.lan` ➞ [Vault](https://www.vaultproject.io)<br>
  - A key-value secrets management vault.
  - Secrets can be accessed by various tools through plugins and integrations.

- 📂 `ldap.homelab.lan` ➞ LDAP authentication server.<br>
  - Currently used by Proxmox nodes and Grafana.

- 🔥 `prometheus.homelab.lan` ➞ [Prometheus](https://prometheus.io/)<br>
  - A monitoring and alerting system.
  - Uses Prometheus and Alertmanager.

- ✅ `ca.homelab.lan` ➞ Internal Certificate Authority (CA).<br>
  - `stackstorm.homelab.lan` manages certificate issuance through automated workflows.

- ⏰ `ntp.homelab.lan` ➞ [Chrony NTP Server](https://chrony-project.org)<br>
  - Provides time synchronization for all VMs without relying on external sources.

- 📊 `grafana.homelab.lan` ➞ [Grafana](https://grafana.com)<br>
  - Visualization for monitoring dashboards: ELK status, VM performance, and more.

- 📜 `elk.homelab.lan` ➞ [Elastic Stack](https://www.elastic.co/elastic-stack)<br>
  - A centralized logging system using Elasticsearch, Logstash, and Kibana.
  - Collects logs via rsyslog, processes them, and presents dashboards.

- 🚀 `api.homelab.lan` ➞ [FastAPI](https://fastapi.tiangolo.com/)<br>
  - An API server for practice and development.

- 📚 `pdns.homelab.lan` ➞ [PowerDNS Authoritative Server](https://doc.powerdns.com/authoritative/index.html)<br>
  - Authoritative DNS server.

- 📗 `recursor.homelab.lan` ➞ [PowerDNS Recursor](https://doc.powerdns.com/recursor/index.html)<br>
  - Recursive DNS resolver.

- 🐳 `docker.homelab.lan` ➞ [Docker](https://www.docker.com)<br>
  - Dedicated machine for building and deploying containerized applications.

- 👷🏻‍♂️ `build.homelab.lan` ➞ Machine for building Debian packages.

- 🐧 `aptly.homelab.lan` ➞ [Aptly](https://www.aptly.info)<br>
  - Manages Debian package repositories.

- 🔀 `revproxy.homelab.lan` ➞ Reverse proxy server.<br>
  - Handles outbound traffic for services like `khaddict.com`.

- 💻 `kcli.homelab.lan` ➞ Kubernetes CLI for managing the cluster.

- 🔩 `kworker0[1-3].homelab.lan` ➞ Kubernetes worker nodes.

- 🔧 `kcontrol0[1-3].homelab.lan` ➞ Kubernetes control plane nodes.

- 💾 `pbs.homelab.lan` ➞ [Proxmox Backup Server](https://www.proxmox.com/en/products/proxmox-backup-server/overview)<br>
  - Proxmox Backup Server for backing up & restoring VMs.

- 🗃️ `storage.homelab.lan` ➞ NFS storage to handle Proxmox backups via PBS.

This documentation provides an overview of my homelab and the various technologies I am working with. More details will be added over time as I refine and expand my setup.
