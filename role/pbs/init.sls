{% set shadowdrive_user = salt['vault'].read_secret('kv/proxmox').shadowdrive_user %}
{% set shadowdrive_encrypted_password = salt['vault'].read_secret('kv/proxmox').shadowdrive_encrypted_password %}

include:
  - base.rclone

rclone_config:
  file.managed:
    - name: /root/.config/rclone/rclone.conf
    - source: salt://role/pbs/files/rclone.conf
    - mode: 600
    - user: root
    - group: root
    - template: jinja
    - context:
        shadowdrive_user: {{ shadowdrive_user }}
        shadowdrive_encrypted_password: {{ shadowdrive_encrypted_password }}

rclone_sync_service:
  file.managed:
    - name: /etc/systemd/system/rclone-sync.service
    - source: salt://role/pbs/files/rclone-sync.service
    - mode: 644
    - user: root
    - group: root

rclone_sync_timer:
  file.managed:
    - name: /etc/systemd/system/rclone-mount.timer
    - source: salt://role/pbs/files/rclone-mount.timer
    - mode: 644
    - user: root
    - group: root

start_enable_rclone_sync_service:
  service.running:
    - name: rclone-sync.service
    - enable: True
    - require:
      - file: rclone_sync_service

start_enable_rclone_sync_timer:
  service.running:
    - name: rclone-sync.timer
    - enable: True
    - require:
      - file: rclone_sync_timer
