build-essential:
  pkg.installed

debhelper:
  pkg.installed

/root/homelab-blackbox-exporter_amd64:
  file.recurse:
    - source: salt://role/build/files/homelab-blackbox-exporter_amd64
    - include_empty: True

/root/homelab-elastic-exporter_amd64:
  file.recurse:
    - source: salt://role/build/files/homelab-elastic-exporter_amd64
    - include_empty: True

/root/packages:
  file.directory:
    - user: root
    - group: root
