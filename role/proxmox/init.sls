{% set ldap_password = salt['vault'].read_secret('kv/ldap').proxmox_pass %}
{% set shadowdrive_user = salt['vault'].read_secret('kv/proxmox').shadowdrive_user %}
{% set shadowdrive_encrypted_password = salt['vault'].read_secret('kv/proxmox').shadowdrive_encrypted_password %}
{% import_json 'data/main.json' as data %}
{% set fqdn = grains["fqdn"] %}
{% set host = grains["host"] %}

user_cfg_file:
  file.managed:
    - name: /etc/pve/user.cfg
    - source: salt://role/proxmox/files/user.cfg
    - user: root
    - group: www-data
    - mode: 640
    - makedirs: True

domains_cfg_file:
  file.managed:
    - name: /etc/pve/domains.cfg
    - source: salt://role/proxmox/files/domains.cfg
    - user: root
    - group: www-data
    - mode: 640
    - makedirs: True

jobs_cfg_file:
  file.managed:
    - name: /etc/pve/jobs.cfg
    - source: salt://role/proxmox/files/jobs.cfg
    - user: root
    - group: www-data
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
        backup_storage: {{ data.proxmox_backups.backup_storage }}
        proxmox_backups:
          {% for vm in data.proxmox_vms %}
          - id: {{ vm.vmid }}
            schedule: {{ vm.schedule }}
          {% endfor %}

ldap_pw_file:
  file.managed:
    - name: /etc/pve/priv/ldap/ldap.pw
    - source: salt://role/proxmox/files/ldap.pw
    - user: root
    - group: www-data
    - mode: 600
    - makedirs: True
    - template: jinja
    - context:
        ldap_password: {{ ldap_password }}

ksmtuned_conf:
  file.managed:
    - name: /etc/ksmtuned.conf
    - source: salt://role/proxmox/files/ksmtuned.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
