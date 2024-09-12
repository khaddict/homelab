{% set elastic_api_key = salt['vault'].read_secret('kv/elk').elastic_api_key %}

install_homelab_elastic_exporter:
  pkg.installed:
    - name: homelab-elastic-exporter

homelab_elastic_exporter_config:
  file.managed:
    - name: /etc/default/homelab-elastic-exporter
    - source: salt://base/elastic_exporter/files/homelab-elastic-exporter
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
        elastic_api_key: {{ elastic_api_key }}
