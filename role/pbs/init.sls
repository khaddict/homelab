{% set shadowdrive_user = salt['vault'].read_secret('kv/proxmox').shadowdrive_user %}
{% set shadowdrive_encrypted_password = salt['vault'].read_secret('kv/proxmox').shadowdrive_encrypted_password %}

include:
  - base.rclone

/mnt/shadowDrive/pbs_backups/.chunks:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/root/.config/rclone/rclone.conf:
  file.managed:
    - source: salt://role/pbs/files/rclone.conf
    - mode: 600
    - user: root
    - group: root
    - makedirs: True
    - template: jinja
    - context:
        shadowdrive_user: {{ shadowdrive_user }}
        shadowdrive_encrypted_password: {{ shadowdrive_encrypted_password }}

/etc/systemd/system/rclone-sync.service:
  file.managed:
    - source: salt://role/pbs/files/rclone-sync.service
    - mode: 644
    - user: root
    - group: root

/etc/systemd/system/rclone-sync.timer:
  file.managed:
    - source: salt://role/pbs/files/rclone-sync.timer
    - mode: 644
    - user: root
    - group: root

enable_rclone_sync_service:
  service.enabled:
    - name: rclone-sync.service
    - require:
      - file: /etc/systemd/system/rclone-sync.service
    - watch:
      - file: /etc/systemd/system/rclone-sync.service

enable_rclone_sync_timer:
  service.running:
    - name: rclone-sync.timer
    - enable: True
    - require:
      - file: /etc/systemd/system/rclone-sync.service
      - file: /etc/systemd/system/rclone-sync.timer
    - watch:
      - file: /etc/systemd/system/rclone-sync.timer

/etc/apt/trusted.gpg.d/proxmox-backup-server-bookworm.gpg:
  file.managed:
    - source: salt://role/pbs/files/proxmox-backup-server-bookworm.gpg
    - mode: 644
    - user: root
    - group: root

proxmox-backup-server-bookworm.list:
  pkgrepo.managed:
    - name: deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/proxmox-backup-server-bookworm.gpg] http://download.proxmox.com/debian/pbs bookworm pbs-no-subscription
    - file: /etc/apt/sources.list.d/proxmox-backup-server-bookworm.list
    - require:
      - file: /etc/apt/trusted.gpg.d/proxmox-backup-server-bookworm.gpg

proxmox-backup-server:
  pkg.installed
