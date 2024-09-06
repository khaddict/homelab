install_build_essential:
  pkg.installed:
    - name: build-essential

install_debhelper:
  pkg.installed:
    - name: debhelper

homelab_blackbox_exporter_amd64_directory:
  file.recurse:
    - name: /root/homelab-blackbox-exporter_amd64
    - source: salt://role/build/files/homelab-blackbox-exporter_amd64
    - include_empty: True

packages_dir:
  file.directory:
    - name: /root/packages
    - user: root
    - group: root
