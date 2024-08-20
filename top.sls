{{ saltenv }}:
# All hosts configuration
  '*':
    - global

# Per role configuration
  'n?-cls?.homelab.lan':
    - role.proxmox

  'saltmaster.homelab.lan':
    - role.saltmaster

  'main.homelab.lan':
    - role.main

  'pihole.homelab.lan':
    - role.pihole

  'stackstorm.homelab.lan':
    - role.stackstorm

  'netbox.homelab.lan':
    - role.netbox

  'vault.homelab.lan':
    - role.vault

  'web??.homelab.lan':
    - role.web

  'ha??.homelab.lan':
    - role.ha

  'ldap.homelab.lan':
    - role.ldap

  'prometheus.homelab.lan':
    - role.prometheus

  'ca.homelab.lan':
    - role.ca

  'ntp.homelab.lan':
    - role.ntp

  'grafana.homelab.lan':
    - role.grafana

  'elk.homelab.lan':
    - role.elk

  'api.homelab.lan':
    - role.api

  'pdns.homelab.lan':
    - role.pdns

  'smtp.homelab.lan':
    - role.smtp

  'ansible.homelab.lan':
    - role.ansible

  'terraform.homelab.lan':
    - role.terraform

  'docker.homelab.lan':
    - role.docker

  'kubernetes.homelab.lan':
    - role.kubernetes

  'build.homelab.lan':
    - role.build

  'aptly.homelab.lan':
    - role.aptly

  'openstack.homelab.lan':
    - role.openstack

  'work.homelab.lan':
    - role.work

  'yacine.homelab.lan':
    - role.yacine
