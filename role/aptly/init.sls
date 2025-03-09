{% import_yaml 'data/packages.yaml' as pkgs %}
{% set homelab_blackbox_exporter_version = pkgs.homelab_packages.homelab_blackbox_exporter_amd64 %}
{% set homelab_elastic_exporter_version = pkgs.homelab_packages.homelab_elastic_exporter_amd64 %}

install_aptly:
  pkg.installed:
    - name: aptly

aptly_service:
  file.managed:
    - name: /etc/systemd/system/aptly.service
    - source: salt://role/aptly/files/aptly.service
    - mode: 644
    - user: root
    - group: root

start_enable_aptly_service:
  service.running:
    - name: aptly
    - enable: True
    - watch:
      - file: aptly_service

download_homelab_elastic_exporter_pkg:
  file.managed:
    - name: /root/homelab_packages/homelab-elastic-exporter_{{ homelab_elastic_exporter_version }}_amd64.deb
    - source: https://github.com/khaddict/homelab/releases/download/homelab-elastic-exporter-v{{ homelab_elastic_exporter_version }}/homelab-elastic-exporter_{{ homelab_elastic_exporter_version }}_amd64.deb
    - makedirs: True
    - user: root
    - group: root
    - mode: 644
    - skip_verify: True

download_homelab_blackbox_exporter_pkg:
  file.managed:
    - name: /root/homelab_packages/homelab-blackbox-exporter_{{ homelab_blackbox_exporter_version }}_amd64.deb
    - source: https://github.com/khaddict/homelab/releases/download/homelab-blackbox-exporter-v{{ homelab_blackbox_exporter_version }}/homelab-blackbox-exporter_{{ homelab_blackbox_exporter_version }}_amd64.deb
    - makedirs: True
    - user: root
    - group: root
    - mode: 644
    - skip_verify: True
