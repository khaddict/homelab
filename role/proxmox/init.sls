{% set ldap_password = salt['vault'].read_secret('kv/ldap').proxmox_pass %}
{% import_json 'data/main.json' as data %}
{% set fqdn = grains["fqdn"] %}
{% set host = grains["host"] %}

/etc/pve/user.cfg:
  file.managed:
    - source: salt://role/proxmox/files/user.cfg
    - user: root
    - group: www-data
    - mode: 640
    - makedirs: True

/etc/pve/domains.cfg:
  file.managed:
    - source: salt://role/proxmox/files/domains.cfg
    - user: root
    - group: www-data
    - mode: 640
    - makedirs: True

/etc/pve/jobs.cfg:
  file.managed:
    - source: salt://role/proxmox/files/jobs.cfg
    - user: root
    - group: www-data
    - mode: 640
    - makedirs: True
    - template: jinja
    - context:
        storage: {{ data.proxmox_backups.backup_storage }}
        vms: {{ data.proxmox_vms }}

/etc/pve/priv/ldap/ldap.pw:
  file.managed:
    - source: salt://role/proxmox/files/ldap.pw
    - user: root
    - group: www-data
    - mode: 600
    - makedirs: True
    - template: jinja
    - context:
        ldap_password: {{ ldap_password }}

/etc/ksmtuned.conf:
  file.managed:
    - source: salt://role/proxmox/files/ksmtuned.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
