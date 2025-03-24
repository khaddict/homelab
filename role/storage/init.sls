{% set shadowdrive_user = salt['vault'].read_secret('kv/proxmox').shadowdrive_user %}
{% set shadowdrive_encrypted_password = salt['vault'].read_secret('kv/proxmox').shadowdrive_encrypted_password %}

include:
  - base.nfs_kernel_server
  - base.rclone
  - base.fuse

exports_config:
  file.managed:
    - name: /etc/exports
    - source: salt://role/storage/files/exports
    - mode: 644
    - user: root
    - group: root

service_nfs_kernel_server:
  service.running:
    - name: nfs-kernel-server
    - enable: True
    - require:
      - file: exports_config
    - watch:
      - file: exports_config

rclone_config:
  file.managed:
    - name: /root/.config/rclone/rclone.conf
    - source: salt://role/storage/files/rclone.conf
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
    - source: salt://role/storage/files/rclone-sync.service
    - mode: 644
    - user: root
    - group: root

rclone_mount_service:
  file.managed:
    - name: /etc/systemd/system/rclone-mount.service
    - source: salt://role/storage/files/rclone-mount.service
    - mode: 644
    - user: root
    - group: root

start_enable_rclone_sync_service:
  service.running:
    - name: rclone-sync
    - enable: True
    - require:
      - file: rclone_sync_service

start_enable_rclone_mount_service:
  service.running:
    - name: rclone-mount
    - enable: True
    - require:
      - file: rclone_mount_service
