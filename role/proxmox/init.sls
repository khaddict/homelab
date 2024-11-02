{% set ldap_password = salt['vault'].read_secret('kv/ldap').proxmox_pass %}
{% set shadowdrive_user = salt['vault'].read_secret('kv/proxmox').shadowdrive_user %}
{% set shadowdrive_encrypted_password = salt['vault'].read_secret('kv/proxmox').shadowdrive_encrypted_password %}
{% set fqdn = grains["fqdn"] %}
{% set host = grains["host"] %}

include:
  - base.rclone

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

shadowdrive_directory:
  file.directory:
    - name: /mnt/shadowdrive
    - mode: 755
    - user: root
    - group: root
    - makedirs: True

shadowdrive_rclone_config:
  file.managed:
    - name: /root/.config/rclone/rclone.conf
    - source: salt://role/proxmox/files/rclone.conf
    - user: root
    - group: root
    - mode: 600
    - makedirs: True
    - template: jinja
    - context:
        shadowdrive_user: {{ shadowdrive_user }}
        shadowdrive_encrypted_password: {{ shadowdrive_encrypted_password }}

shadowdrive_rclone_service:
  file.managed:
    - name: /etc/systemd/system/shadowdrive-rclone.service
    - source: salt://role/proxmox/files/shadowdrive-rclone.service
    - user: root
    - group: root
    - mode: 644
    - makedirs: True

enable_service_shadowdrive_rclone:
  service.running:
    - name: shadowdrive-rclone
    - enable: True
    - require:
      - file: shadowdrive_rclone_service
