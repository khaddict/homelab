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

  'stackstorm.homelab.lan':
    - role.stackstorm

  'netbox.homelab.lan':
    - role.netbox

  'vault.homelab.lan':
    - role.vault

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

  'recursor.homelab.lan':
    - role.recursor

  'docker.homelab.lan':
    - role.docker

  'build.homelab.lan':
    - role.build

  'aptly.homelab.lan':
    - role.aptly

  'revproxy.homelab.lan':
    - role.revproxy

  'kcontrol0?.homelab.lan':
    - role.kcontrol

  'kcli.homelab.lan':
    - role.kcli

  fileserver.homelab.lan:
    - role.fileserver
