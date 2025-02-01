{{ saltenv }}:
# All hosts configuration
  '*':
    - global

# Per role configuration
  'api.homelab.lan':
    - role.api

  'aptly.homelab.lan':
    - role.aptly

  'assets.homelab.lan':
    - role.assets

  'build.homelab.lan':
    - role.build

  'ca.homelab.lan':
    - role.ca

  'docker.homelab.lan':
    - role.docker

  'elk.homelab.lan':
    - role.elk

  'grafana.homelab.lan':
    - role.grafana

  'kcli.homelab.lan':
    - role.kcli

  'kcontrol0?.homelab.lan':
    - role.kcontrol

  'ldap.homelab.lan':
    - role.ldap

  'main.homelab.lan':
    - role.main

  'n?-cls?.homelab.lan':
    - role.proxmox

  'netbox.homelab.lan':
    - role.netbox

  'ntp.homelab.lan':
    - role.ntp

  'pdns.homelab.lan':
    - role.pdns

  'prometheus.homelab.lan':
    - role.prometheus

  'recursor.homelab.lan':
    - role.recursor

  'revproxy.homelab.lan':
    - role.revproxy

  'saltmaster.homelab.lan':
    - role.saltmaster

  'stackstorm.homelab.lan':
    - role.stackstorm

  'vault.homelab.lan':
    - role.vault

  'wiki.homelab.lan':
    - role.wiki

  'work.homelab.lan':
    - role.work
