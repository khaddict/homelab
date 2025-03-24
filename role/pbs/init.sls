include:
  - base.nfs_common

mnt_pbs_dir:
  file.directory:
    - name: /mnt/pbs
    - user: root
    - group: root
    - mode: 755

datastore_pbs:
  file.managed:
    - name: /etc/proxmox-backup/datastore.cfg
    - source: salt://role/pbs/files/datastore.cfg
    - mode: 640
    - user: root
    - group: backup
