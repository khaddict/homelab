{% set shadowdrive_user = salt['vault'].read_secret('kv/proxmox').shadowdrive_user %}
{% set shadowdrive_encrypted_password = salt['vault'].read_secret('kv/proxmox').shadowdrive_encrypted_password %}
{% set ldap_password = salt['vault'].read_secret('kv/ldap').proxmox_pass %}

include:
  - base.rclone

/opt/local/pbs_backups:
  file.directory:
    - user: backup
    - group: backup
    - mode: 755
    - makedirs: True

/opt/remote/pbs_backups:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

/usr/local/bin/pbs_backup.sh:
  file.managed:
    - source: salt://role/pbs/files/pbs_backup.sh
    - mode: 755
    - user: root
    - group: root
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

rclone_sync_service:
  service.enabled:
    - name: rclone-sync.service
    - require:
      - file: /etc/systemd/system/rclone-sync.service
    - watch:
      - file: /etc/systemd/system/rclone-sync.service

rclone_sync_timer:
  service.running:
    - name: rclone-sync.timer
    - enable: True
    - require:
      - file: /etc/systemd/system/rclone-sync.service
      - file: /etc/systemd/system/rclone-sync.timer
    - watch:
      - file: /etc/systemd/system/rclone-sync.timer

/usr/share/keyrings/proxmox-archive-keyring.gpg:
  file.managed:
    - source: salt://role/pbs/files/proxmox-archive-keyring.gpg
    - mode: 644
    - user: root
    - group: root

/etc/apt/sources.list.d/proxmox.sources:
  file.managed:
    - source: salt://role/pbs/files/proxmox.sources
    - mode: 644
    - user: root
    - group: root

proxmox-backup-server:
  pkg.installed

/etc/proxmox-backup/domains.cfg:
  file.managed:
    - source: salt://role/pbs/files/domains.cfg
    - user: root
    - group: backup
    - mode: 640
    - makedirs: True

/etc/proxmox-backup/ldap_passwords.json:
  file.managed:
    - source: salt://role/pbs/files/ldap_passwords.json
    - user: root
    - group: www-data
    - mode: 600
    - makedirs: True
    - template: jinja
    - context:
        ldap_password: {{ ldap_password }}
