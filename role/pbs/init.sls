{% set shadowdrive_user = salt['vault'].read_secret('kv/proxmox').shadowdrive_user %}
{% set shadowdrive_encrypted_password = salt['vault'].read_secret('kv/proxmox').shadowdrive_encrypted_password %}

include:
  - base.rclone

mnt_pbs_backups_dir:
  file.directory:
    - name: /mnt/shadowDrive/pbs_backups
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

rclone_config:
  file.managed:
    - name: /root/.config/rclone/rclone.conf
    - source: salt://role/pbs/files/rclone.conf
    - mode: 600
    - user: root
    - group: root
    - makedirs: True
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
    - name: /etc/systemd/system/rclone-sync.timer
    - source: salt://role/pbs/files/rclone-sync.timer
    - mode: 644
    - user: root
    - group: root

start_enable_rclone_sync_service:
  service.running:
    - name: rclone-sync.service
    - enable: True
    - require:
      - file: rclone_sync_service
    - watch:
      - file: rclone_sync_service

start_enable_rclone_sync_timer:
  service.running:
    - name: rclone-sync.timer
    - enable: True
    - require:
      - file: rclone_sync_timer
    - watch:
      - file: rclone_sync_timer

pbs_gpg_key:
  file.managed:
    - name: /etc/apt/trusted.gpg.d/proxmox-backup-server-bookworm.gpg
    - source: salt://role/pbs/files/proxmox-backup-server-bookworm.gpg
    - makedirs: True
    - user: root
    - group: root
    - mode: 644

pbs_repo_pkg:
  pkgrepo.managed:
    - name: deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/proxmox-backup-server-bookworm.gpg] http://download.proxmox.com/debian/pbs bookworm pbs-no-subscription
    - file: /etc/apt/sources.list.d/proxmox-backup-server-bookworm.list
    - require:
      - file: pbs_gpg_key

install_pbs:
  pkg.installed:
    - name: proxmox-backup-server
