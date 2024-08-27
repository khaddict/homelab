install_build_essential:
  pkg.installed:
    - name: build-essential

install_debhelper:
  pkg.installed:
    - name: debhelper

homelab_blackbox_exporter_directory:
  file.recurse:
    - name: /root/homelab-blackbox-exporter
    - source: salt://role/build/files/homelab-blackbox-exporter
    - include_empty: True

packages_dir:
  file.directory:
    - name: /root/packages
    - user: root
    - group: root
