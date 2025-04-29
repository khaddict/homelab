{% import_yaml 'data/packages.yaml' as pkgs %}
{% set homelab_blackbox_exporter_version = pkgs.homelab_packages.homelab_blackbox_exporter_amd64 %}
{% set homelab_elastic_exporter_version = pkgs.homelab_packages.homelab_elastic_exporter_amd64 %}

aptly:
  pkg.installed

/etc/systemd/system/aptly.service:
  file.managed:
    - source: salt://role/aptly/files/aptly.service
    - mode: 644
    - user: root
    - group: root

aptly_service:
  service.running:
    - name: aptly
    - enable: True
    - watch:
      - file: /etc/systemd/system/aptly.service

/root/homelab_packages/homelab-elastic-exporter_{{ homelab_elastic_exporter_version }}_amd64.deb:
  file.managed:
    - source: https://github.com/khaddict/homelab/releases/download/homelab-elastic-exporter-v{{ homelab_elastic_exporter_version }}/homelab-elastic-exporter_{{ homelab_elastic_exporter_version }}_amd64.deb
    - makedirs: True
    - user: root
    - group: root
    - mode: 644
    - skip_verify: True

/root/homelab_packages/homelab-blackbox-exporter_{{ homelab_blackbox_exporter_version }}_amd64.deb:
  file.managed:
    - source: https://github.com/khaddict/homelab/releases/download/homelab-blackbox-exporter-v{{ homelab_blackbox_exporter_version }}/homelab-blackbox-exporter_{{ homelab_blackbox_exporter_version }}_amd64.deb
    - makedirs: True
    - user: root
    - group: root
    - mode: 644
    - skip_verify: True
