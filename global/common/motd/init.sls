hostname_motd_config:
  file.managed:
    - name: /etc/update-motd.d/20-hostname
    - source: salt://global/common/motd/files/20-hostname
    - mode: 755
    - user: root
    - group: root
