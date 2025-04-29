{% set elastic_api_key = salt['vault'].read_secret('kv/elk').elastic_api_key %}

homelab-elastic-exporter:
  pkg.installed

/etc/default/homelab-elastic-exporter:
  file.managed:
    - source: salt://base/elastic_exporter/files/homelab-elastic-exporter
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
        elastic_api_key: {{ elastic_api_key }}
