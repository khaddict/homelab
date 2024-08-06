{% set alertmanager_version = '0.27.0' %}
{% set webhook_url = salt['vault'].read_secret('kv/prometheus').webhook_url %}

alertmanager_user:
  user.present:
    - name: alertmanager
    - usergroup: True
    - createhome: False
    - system: True

extract_alertmanager:
  archive.extracted:
    - name: /etc/
    - source: https://github.com/prometheus/alertmanager/releases/download/v{{ alertmanager_version }}/alertmanager-{{ alertmanager_version }}.linux-amd64.tar.gz
    - user: alertmanager
    - group: alertmanager
    - mode: 755
    - if_missing: /etc/alertmanager
    - skip_verify: True

rename_alertmanager_directory:
  file.rename:
    - name: /etc/alertmanager
    - source: /etc/alertmanager-{{ alertmanager_version }}.linux-amd64
    - require:
      - archive: extract_alertmanager

alertmanager_config:
  file.managed:
    - name: /etc/alertmanager/alertmanager.yml
    - source: salt://role/prometheus/files/alertmanager.yml
    - mode: 644
    - user: alertmanager
    - group: alertmanager
    - require:
      - archive: extract_alertmanager
    - template: jinja
    - context:
        webhook_url: {{ webhook_url }}

alertmanager_service:
  file.managed:
    - name: /etc/systemd/system/alertmanager.service
    - source: salt://role/prometheus/files/alertmanager.service
    - mode: 755
    - user: root
    - group: root
    - require:
      - archive: extract_alertmanager

start_enable_alertmanager_service:
  service.running:
    - name: alertmanager
    - enable: True
    - watch:
      - file: alertmanager_config
