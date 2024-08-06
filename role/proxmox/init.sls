{% set ldap_password = salt['vault'].read_secret('kv/ldap').proxmox_pass %}
{% set fqdn = grains["fqdn"] %}

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

{% if fqdn is match('n1-cls1.homelab.lan') %}
snapshot_vms_script:
  file.managed:
    - name: /opt/snapshot_vms.sh
    - source: salt://role/proxmox/files/snapshot_vms.sh
    - user: root
    - group: root
    - mode: 755

snapshot_vms_service:
  file.managed:
    - name: /etc/systemd/system/snapshot_vms.service
    - source: salt://role/proxmox/files/snapshot_vms.service
    - user: root
    - group: root
    - mode: 755
    - require:
      - file: snapshot_vms_script

snapshot_vms_timer:
  file.managed:
    - name: /etc/systemd/system/snapshot_vms.timer
    - source: salt://role/proxmox/files/snapshot_vms.timer
    - user: root
    - group: root
    - mode: 755
    - require:
      - file: snapshot_vms_script

start_enable_snapshot_vms_service:
  service.dead:
    - name: snapshot_vms.service
    - enable: True
    - require:
      - file: snapshot_vms_service
      - file: snapshot_vms_timer
    - watch:
      - file: snapshot_vms_service
      - file: snapshot_vms_timer

start_enable_snapshot_vms_timer:
  service.running:
    - name: snapshot_vms.timer
    - enable: True
    - require:
      - service: start_enable_snapshot_vms_service
{% endif %}
