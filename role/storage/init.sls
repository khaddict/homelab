include:
  - base.nfs_kernel_server

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
